require 'rubygems'
require 'open-uri'
require 'pp'
require 'pry'
require 'nokogiri'
require 'erb'
require 'sanitize'

@domain = "http://www.paulgraham.com/"


def parse_html_toc
  
  # get table of contents
  toc = Nokogiri::HTML(open(@domain+'articles.html'))

  # build article_meta_info (:link, :title)
  articles = toc.css('tr td font a')[0..-2]  
  article_meta_info = articles.map {|a| {:link => a.attributes['href'].value, :title => a.children.first.text}}
  article_meta_info.reject! {|ami| ami[:link][/txt/] != nil}
  article_meta_info.reverse!
  
  # add article body
  article_meta_info.each_with_index do |ami, i|

    # get article
    begin
      puts "#{i} #{ami[:link]}"
      article = Nokogiri::HTML(open(@domain + ami[:link]))
    
      # parse article
      ami[:body] = Sanitize.clean(article.css('body >table').inner_html, :elements => ['br']).
        gsub(/\n+/," ").gsub(/\.\s*/,'. ').gsub('Want to start a startup?  Get funded by Y Combinator.','').
        split(/<br>+/).map(&:strip).reject(&:empty?).
        map {|text| "<p>#{text}</p>"}.join("\n      ")
    rescue StandardError
      puts "error\n\n\n"
    end
        
  end     
  
end

def build_chapters(article_meta_info)
  
  article_template = %q{<?xml version='1.0' encoding='utf-8'?>
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title><%= @article_title %></title>
    </head>
    <body>
      <h2><%= @article_title %></h2>
      <%= @article_body %>
    </body>
  </html>
  }
  
  # delete existing chapters
  Dir['Book/content/c*.html'].each {|c| File.delete(c)}
  
  # write new chapters
  article_meta_info.each_with_index do |ami,i|
    @article_body = ami[:body]
    @article_title = ami[:title]
    doc = File.new("Book/content/c#{i}_#{ami[:link]}", "w")
    doc.puts ERB.new(article_template, 0, "%<>").result
    doc.close
  end
end


def build_toc(article_meta_info)
  toc_template = %q{<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
    <head>
      <meta name="dtb:uid" content="Paul Grahams Essays [2012.1.8-18:32:00]"/>
      <meta name="dtb:depth" content="1"/>
      <meta name="dtb:totalPageCount" content="0"/>
      <meta name="dtb:maxPageNumber" content="0"/>
    </head>
    <docTitle>
      <text>Paul Graham's Essays</text>
    </docTitle>
    <navMap>
      <% article_meta_info.each_with_index do |ami,i| %>
      <navPoint id="navpoint-<%= i+1 %>" playOrder="<%= i+1 %>">
         <navLabel>
           <text><%= ami[:title] %></text>
         </navLabel>
         <content src="content/<%= "c#{i}_#{ami[:link]}" %>"/>
       </navPoint>
       <% end %>
    </navMap>
  </ncx>
  }

  doc = File.new("Book/toc.ncx", "w")
  doc.puts ERB.new(toc_template, 0, "%<>").result
  doc.close

end

def build_metadata(article_meta_info)
  
  metadata_tempate = %q{<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="bookid">
      <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
        <dc:title>Paul Graham's Essays</dc:title>
        <dc:creator opf:file-as="Graham, Paul" opf:role="aut">Paul Graham</dc:creator>
        <dc:language>en-US</dc:language>
        <dc:identifier id="bookid">Paul Grahams Essays [2012.1.8-18:32:00]</dc:identifier>
        <dc:rights>Public Domain</dc:rights>
      </metadata>
      <manifest>
        <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
        <item id="titlepage" href="content/title.html" media-type="application/xhtml+xml"/>
        <% @articles.each do |article| %>
        <item id="<%= article %>" href="content/<%= article %>.html" media-type="application/xhtml+xml"/>
        <% end %>
       </manifest>
      <spine toc="ncx">
        <% @articles.each do |article| %>
        <itemref idref="<%= article %>"/>
        <% end %>
      </spine>
  </package>
  }
  
  # get list of chapters
  @articles = Dir['Book/content/c*.html'].map {|c| c.gsub(/\w+\/\w+\/(\S+)\.html/, '\1')}
  
  # write metadata
  doc = File.new("Book/metadata.opf", "w")
  doc.puts ERB.new(metadata_tempate, 0, "%<>").result
  doc.close

end
  
  
article_meta_info = parse_html_toc
build_chapters(article_meta_info)
build_metadata(article_meta_info)
build_toc(article_meta_info)
binding.pry
puts "hello"

# build_chapters(article_meta_info)
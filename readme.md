## PG's collections of articles in epub format

### Summary
Paul Graham's essay's are tremendously influential in the startup / programming world. His essays are freely available on his website, but are not made available in other formats. I wanted to be able to easily read his essays on my kindle, which I do most of my reading on, so i wrote a simple script that pulled in his essays and formatted them appropriately. 


### errata
This version is knowingly flawed. There are some essays that were not parsed correctly. If you're enjoying the epub version and would lie to make a small change, please modify the script and create a pull request. 

### useful commands
zip -Xr9D PGEssays.epub mimetype * -x .DS_Store
java -jar ~/src/other-languages/java/epubcheck-1.2/epubcheck-1.2.jar PGEssays.epub
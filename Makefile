all: prep install

help:
	@echo "Run 'make install' to install, 'make uninstall' to uninstall and 'make prep' to prepare for git push."

prep: collage README.md collage.1

install: collage collage.1
	@echo install
	@bash install.sh
	@bash install.sh -d

uninstall:
	@echo uninstall
	@bash install.sh -u


collage: prep/collage prep/collage.meta
	@echo collage
	@bash makedoc.sh help > collage

README.md: prep/README.md prep/collage.meta
	@echo README.md
	@bash makedoc.sh readme > README.md

collage.1: prep/collage.1 prep/collage.meta
	@echo collage.1
	@bash makedoc.sh man > collage.1

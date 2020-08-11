# collage
**Create collage from images**

Front end to ImageMagick and GraphicsMagick for creating collage of image files and text.

## Installation
	curl -LO https://github.com/bashdroid/collage/archive/master.tar.gz  
	tar xzf master.tar.gz  
	cd collage-master  
	make install  

Depending on your system, you might need to run `make install` as root.  

If you don't need a manual, you may just download and run **collage** with your preferred tools, e.g.:  

	curl -LO https://raw.githubusercontent.com/bashdroid/collage/master/collage  
	chmod u+x collage

## Dependencies
* imagemagick or graphicsmagick  
* bc

## Rationale
The motivation for creating this tool came from dissatisfaction with existing photo book editors. With those tools, it is impossible to export your work as pdf, they produce inaccurate results, create humongous amounts of data, are not automatable and offer only limited functionality on mobile devices.  

This tool is designed such that all numeric arguments are percentages (and not pixels) to allow for intuitive usage and for invariance against rescaling. You may use both ImageMagick and GraphicsMagick as backend, since both of these have their advantages and disadvantages.

## Usage
### Synopsis
**collage** \[G-OPT\] *FILE1* \[F-OPT\] \[A-OPT *FILE2* [F-OPT] ...\]  
**collage** I-OPT

### Options
##### Global options [G-OPT]:  
Global options precede all input images.  
**-b** *P*   &nbsp;&nbsp;set inner border (between images) to *P*% of min(width,height)  
**-B** *P*   &nbsp;&nbsp;set outer border (between images and canvas edge) to *P*% of min(width,height)  
**-c** *W*x*H* &nbsp;&nbsp;set canvas width = *W*, canvas height = *H* pixels (if output exists, defaults to output dimensions)  
**-C** *N*   &nbsp;&nbsp;set canvas color to color name *N*  
**-m** *X*   &nbsp;&nbsp;set mat size to *X* pixels  
**-M** *N*   &nbsp;&nbsp;set mat color to color name *N*  
**-o** *F*   &nbsp;&nbsp;write output to file *F*  
**-s**       &nbsp;&nbsp;print script, instead of producing output image  
**-t** *S*   &nbsp;&nbsp;use string *S* as settings for drawing text  

##### Arrangement options [A-OPT]:  
Arrangement options are between two input images I and J. You may use brackets, ( and ), to change the order of operation.  
**-v** *X*   &nbsp;&nbsp;place image *J* to the right of image *I*, after vertical section of *X*% of min(width,height)  
**-h** *X*   &nbsp;&nbsp;place image *J* below image *I*, after horizontal section of *X*% of min(width,height)  

##### File-specific options [F-OPT]:  
File-specific options are after the corresponding input image *I*.  
**-r**|**-R**|**+r**  &nbsp;&nbsp;rotate image *I* by 90|180|270 degrees  
**-s** *X*   &nbsp;&nbsp;If *X*=*A*x*B*, shift image *I* by *A*% to the right and *B*% to the bottom. (0%=left/top, 50%=center, 100%=right/bottom) If *X* is a number *N*, act as if *X*=*N*x100 or *X*=100x*N* (depending on whether input or output aspect ratio is bigger).  
**-z** *X*   &nbsp;&nbsp;zoom to *X*% of length/height of input image  

##### Information options [I-OPT]:  
**-h**|**--help** &nbsp;&nbsp;print help  
**-v**|**--version** &nbsp;&nbsp;print version  
**-c**|**--config** &nbsp;&nbsp;print configuration settings

### Arguments
In standard case, *FILE* is an image file recognized by ImageMagick or GraphicsMagick. If *FILE* is not a regular file, the string *FILE* is printed in place of an image. If *FILE* is NULL, the corresponding section remains empty.

### Files
Config settings are evaluated in the following order of precedence:  
* Global options [G-OPT]  
* *.collage.conf* (in current working directory)  
* *~/.config/collage.conf* 
* hard-coded defaults  

Config files have a simple "name=value" syntax. The following variables may be specified:  
* **resize** (= -scale or -resize)  
* **backend** (= im or gm)  
* **auto_or** (= T or F, auto-orient images with meta data rotation)  
* **out_exist_action** (= r[eplace], o[verlay], a[bort])  
* **output** (corresponds to **-o**)  
* **canvas_dim** (corresponds to **-c**)  
* **canvas_color** (corresponds to **-C**)  
* **mat_size** (corresponds to **-m**)  
* **mat_color** (corresponds to **-M**)  
* **inner_border** (corresponds to **-b**)  
* **outer_border** (corresponds to **-B**)  
* **text_settings** (corresponds to **-t**)  
* **output_script** (corresponds to **-s**)

## Security
**collage** sources file *.collage.conf* in the current working directory. This is a possible security threat if an attacker has write access to your working directory. To mitigate this risk, a simple security check was implemented in function **safe_source()**. If you prefer more (e.g. no sourcing) or less (e.g. no checking) security, you can simply change this function.

## Examples
Create a triptych with 5% spacing between the images:  

    collage -b5 -o triptych.jpg left.jpg -v25 middle.jpg -v50 right.jpg

#!/bin/sh
# Purpose: free-air gravity of Mexico
# GMT modules: gmtset, gmtdefaults, img2grd, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert, pscoast
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/h5/index.html

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

gmt img2grd curv_27.1.img -R240/275/14/33 -Ggrav_MX_v.grd  -T1 -I1 -E -S0.1 -V
gdalinfo grav_MX_v.grd -stats
# Minimum=-683.562, Maximum=674.738, Mean=-0.104, StdDev=31.189

# Generate a color palette table from grid
# gmt makecpt --help
# gmt makecpt -Chaxby -T-342/460 > colors.cpt
gmt makecpt -Cwysiwyg.cpt -T-50/100 > colors.cpt
#-Ic Reverse sense of color table spectrum

# Generate a file
ps=Grav_MX_v.ps

gmt grdimage grav_MX_v.grd  -Ccolors.cpt -R240/275/14/33 -JM6.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add isolines
gmt grdcontour grav_MX_v.grd  -R -J -C1000 -Wthinnest -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx4f2a4 -Bpyg8f4a4 -Bsxg4 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=9p,25,black \
    --FONT_TITLE=13p,25,black \
    -B+t"Vertical gravity gradient for Mexico" -O -K >> $ps
    
# Add legend
gmt psscale -Dg240/11.7+w16.5c/0.4c+h+o0.0/0i+ml+e -R -J -Ccolors.cpt \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=8p,25,black \
    -Bg5f1a10+l"Color scale 'wysiwyg' 20 well-separated RGB colors [C=RGB, -T-150/150]" \
    -I0.2 -By+l"mGal" -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.8c/-2.3c+c50+w500k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-70p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thick,white -Wthin,darkslategray -Df -O -K >> $ps

# Texts

# Add GMT logo
gmt logo -Dx7.0/-2.9+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y0.9c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
1.0 14.5 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution, SIO, NOAA, NGA.
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_MX_v.ps -A0.5c -E720 -Tj -Z

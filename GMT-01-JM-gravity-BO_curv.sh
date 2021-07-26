#!/bin/sh
# Purpose: vertical gravity gradient of Bolivia
# GMT modules: gmtset, gmtdefaults, img2grd, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert, pscoast
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/pj/4/index.html

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

gmt img2grd curv_27.1.img -R290/302.5/-23/-9 -Ggrav_v_BO.grd -T1 -I1 -E -S0.1 -V
gdalinfo grav_v_BO.grd -stats
# Minimum=-491.990, Maximum=614.539, Mean=0.857, StdDev=49.542

# Generate a color palette table from grid
# gmt makecpt --help
# gmt makecpt -Chaxby -T-342/460 > colors.cpt
gmt makecpt -Chaxby -T-180/180 > colors.cpt
#-Ic Reverse sense of color table spectrum

# Generate a file
ps=Grav_BO_v.ps

gmt grdimage grav_v_BO.grd -Ccolors.cpt -R290/302.5/-23/-9 -JM6.0i -P -I+a15+ne0.75 -Xc -K > $ps

# Add isolines
gmt grdcontour grav_v_BO.grd -R -J -C200 -A400 -Wthinner -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx4f2a2 -Bpyg4f2a2 -Bsxg2 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,25,black \
    -B+t"Vertical gravity gradient for Bolivia" -O -K >> $ps
    
# Add legend
gmt psscale -Dg290/-23.8+w15.2c/0.4c+h+o0.0/0i+ml+e -R -J -Ccolors.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=8p,25,black \
    -Bg50f5a50+l"Color scale 'haxby' B. Haxby's color scheme for geoid & gravity [C=RGB -T-200/200]" \
    -I0.2 -By+l"mGal" -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx12.7c/-2.3c+c50+w200k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-65p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thick,white -Wthin,darkslategray -Df -O -K >> $ps

# Texts

# Add GMT logo
gmt logo -Dx6.2/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.5c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
0.5 13.6 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution, SIO, NOAA, NGA.
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_BO_v.ps -A0.5c -E720 -Tj -Z

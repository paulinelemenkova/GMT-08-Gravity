#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: Indian Ocean).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,gray30 \
    MAP_GRID_CROSS_SIZE_PRIMARY=0.5c \
    MAP_ANNOT_OFFSET=0.1c \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    MAP_LABEL_OFFSET=0.1c
    
# Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R110/295/-70/70 -Ggrav.grd -T1 -I1 -E -S0.1 -V

# Generate a color palette table from grid
gdalinfo geoid.egm96.grd -stats
#Minimum=-106.505, Maximum=86.417, Mean=-0.808, StdDev=29.198
# gmt grd2cpt grav.grd -Crainbow > grav.cpt
gmt makecpt -Chaxby -T-106.505/86.417/1 > colors.cpt

# Step-1. Generate a file
ps=Grav_PO.ps
# Generate gravity image with shading
gmt grdimage grav.grd -I+a45+nt1 -R110/295/-70/70 -JY180/0/6.5i -Ccolors.cpt -P -K > $ps

# Step-6. Add basemap: grid, title, coastline
gmt psbasemap -R -J \
    -Bxg20f10a10 -Byg20f10a10 \
    --MAP_TITLE_OFFSET=0.8c \
    -B+t"Marine free-air gravity anomaly: Pacific Ocean" -O -K >> $ps
    
# Step-7. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx14c/-1.2c+c50+w3000k+l"Behrman cylindrical equal-area prj. Scale: km"+f \
    -UBL/0.0c/-1.5c -O -K >> $ps
    
# Step-8. Add legend
gmt psscale -Dg85/-70+w9.5c/0.4c+v+o0.3/0i+ml \
    -Rpo_relief.nc -J -Ccolors.cpt \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
    -Baf+l"Color scale: Haxby: Bill Haxby's color scheme for geoid & gravity [C=RGB]" \
    -I0.2 -By+lmGal -O -K >> $ps
    
# Step-0. Add logo
gmt logo -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X1.0c -Y4.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.2 8.8 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
EOF

# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_PO.ps -A0.2c -E720 -Tj -P -Z

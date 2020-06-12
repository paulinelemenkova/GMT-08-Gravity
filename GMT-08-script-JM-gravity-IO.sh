#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: Indian Ocean).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert
# Step-1. Generate a file
ps=Grav_IO.ps
# Step-2. GMT set up
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
    
# Step-3. Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R20/120/-65/30 -Ggrav.grd -T1 -I1 -E -S0.1 -V

# Step-4. Generate a color palette table from grid
gdalinfo geoid.egm96.grd -stats
#Minimum=-106.505, Maximum=86.417, Mean=-0.808, StdDev=29.198
# gmt grd2cpt grav.grd -Crainbow > grav.cpt
gmt makecpt -Chaxby -T-106.505/86.417/1 > colors.cpt

# Step-5. Generate gravity image with shading
gmt grdimage grav.grd -I+a45+nt1 -R20/120/-65/30 -JQ5.0i -Ccolors.cpt -P -K > $ps

# Step-6. Add basemap: grid, title, coastline
gmt pscoast -R -J -P \
    -V -W0.25p \
    -Df -B+t"Marine free-air gravity anomaly: Indian Ocean" \
    --MAP_TITLE_OFFSET=0.8c \
    -Bpx204f10a10 -Bpyg20f10a10 -Bsxg5 -Bsyg5 \
    -O -K >> $ps
    
# Step-7. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=6p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx0.8c/10.3c+w0.3i+f2+l+o0.15i \
    -Lx11c/-1.3c+c50+w2000k+l"Cylindrical equidistant prj. Scale: km"+f \
    -UBL/-10p/-40p -O -K >> $ps
    
# Step-8. Add legend
gmt psscale -Dg1.0/-65+w12.0c/0.4c+v+o0.3/0i+ml -R20/120/-65/30 -J -Ccolors.cpt \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Haxby: Bill Haxby's color scheme for geoid & gravity [C=RGB]" \
    -I0.2 -By+lmGal -O -K >> $ps
    
# Step-0. Add logo
gmt logo -Dx5.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.3c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.7 11.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
EOF

# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_IO.ps -A0.2c -E720 -Tj -P -Z

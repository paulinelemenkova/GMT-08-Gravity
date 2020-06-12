#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: Manila Trench).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert
# Step-1. Generate a file
ps=Grav_MnT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1.0c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinner,white \
    MAP_GRID_CROSS_SIZE_PRIMARY=1.0c \
    MAP_ANNOT_OFFSET=0.1c \
    FONT_TITLE=14p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    MAP_LABEL_OFFSET=0.1c
# Step-3. Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R105/123/8/24 -GgravRT.grd -T1 -I1 -E -S0.1 -V
# Step-4. Generate a color palette table from grid
gmt grd2cpt gravRT.grd -Crainbow > gravRT.cpt
# Step-5. Generate gravity image with shading
gmt grdimage gravRT.grd -I+a45+nt1 -R105/123/8/24 -JY114/12/6.5i -CgravRT.cpt -P -K > $ps
# Step-6. Add basemap: grid, title, costline
gmt pscoast -R -J -P \
	-V -W0.25p \
    -Df -B+t"Marine free-air gravity anomaly for the Manila Trench area" \
	-Bxg3f2a2 -Byg3f2a2 \
    -O -K >> $ps
# Step-7. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,black \
    --MAP_ANNOT_OFFSET=.2c \
    --MAP_TITLE_OFFSET=.3c \
    -Tdg158/62+w0.5c+f2+l \
    -Lx5.0i/-0.5i+c50+w400k+l"Cylindrical Equal-Area Gall-Peters projection. Scale, km"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-8. Add color legen3
gmt psscale -R -J -CgravRT.cpt \
    -Dg102.0/8+w15.0c/0.5c+v+o0.7/0i+ml  \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.1c \
    -Bxg100f20a100+l"Marine free-air gravity anomaly color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
# Step-0. Add logo
gmt logo -R -J -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X-0.7c -Y5.5c -N -O \
    -F+f12p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 15.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
EOF
# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_MnT.ps -A0.2c -E720 -Tj -P -Z

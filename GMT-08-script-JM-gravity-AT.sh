#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: Aleutian Trench).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert
# Step-1. Generate a file
ps=Grav_AT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1.0c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,gray30 \
    MAP_GRID_CROSS_SIZE_PRIMARY=0.5c \
    MAP_ANNOT_OFFSET=0.1c \
    FONT_TITLE=14p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    MAP_LABEL_OFFSET=0.1c
# Step-3. Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R154/220/40/65 -GgravAT.grd -T1 -I1 -E -S0.1 -V
# Step-4. Generate a color palette table from grid
gmt grd2cpt gravAT.grd -Crainbow > gravAT.cpt
# Step-5. Generate gravity image with shading
gmt grdimage gravAT.grd -I+a45+nt1 -R154/220/40/65 -JY188/55/6.5i -CgravAT.cpt -P -K > $ps
# Step-6. Add basemap: grid, title, costline
gmt pscoast -R -J -P \
	-V -W0.25p \
    -Df -B+t"Marine free-air gravity anomaly for the Aleutian Trench area" \
	-Bxg3f4a8 -Byg3f2a4 \
    -O -K >> $ps
# Step-7. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_ANNOT_OFFSET=.15c \
    --MAP_TITLE_OFFSET=.3c \
    -Tdg158/62+w0.5c+f2+l \
    -Lx5.0i/-0.5i+c50+w1500k+l"Cylindrical Equal-Area Gall-Peters projection. Scale, km"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-8. Add color legen3
gmt psscale -R -J -CgravAT.cpt \
    -Dg142/40+w11.0c/0.5c+v+o0.7/0i+ml  \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=7p,Palatino-Roman,dimgray \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.1c \
    -Bxg100f20a100+l"Marine free-air gravity anomaly color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
# Step-0. Add logo
gmt logo -R -J -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y2.2c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 15.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
EOF
# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_AT.ps -A0.2c -E720 -Tj -P -Z

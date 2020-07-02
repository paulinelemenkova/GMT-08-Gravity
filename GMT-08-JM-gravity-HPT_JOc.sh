#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: New Zealand, Hikurangi, Puysegur and Hjort trenches).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert
# Step-1. Generate a file
ps=Grav_PHT.ps
# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1.5c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinner,white \
    MAP_GRID_PEN_SECONDARY=thin,white \
    MAP_ANNOT_OFFSET=0.1c \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    MAP_LABEL_OFFSET=0.1c
# Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R145/186/-65/-27 -Ggrav.grd -T1 -I1 -E -S0.1 -V
# gdalinfo grav.grd -stats
# Min=-155.097 Max=366.939
# Generate a color palette table from grid
# gmt grd2cpt grav.grd -Crainbow > grav.cpt
# gmt makecpt -Cturbo.cpt > grav.cpt
gmt grd2cpt grav.grd -Chaxby > geoid.cpt

# Generate gravity image with shading
gmt grdimage grav.grd -I+a45+nt1 \
    -R145/-62/186/-30r -JOc165/-29.5/-100/85/16c\
    -Cgeoid.cpt -P -K > $ps

# Add basemap: grid, title, costline
gmt pscoast -R -J -P \
	-V -W0.25p -Df \
    -B+t"Marine free-air gravity anomaly: New Zealand, Hikurangi, Puysegur and Hjort" \
    --FONT_ANNOT_PRIMARY=10p,Helvetica,black \
    --MAP_TITLE_OFFSET=1.7c \
    --FONT_TITLE=15p,Helvetica,black \
    -Bpxg10f5a10 -Bpyg5f2a4 -Bsxg10 -Bsyg4 -O -K >> $ps

# Add color legend
gmt psscale -R -J -Cgeoid.cpt \
    -Dg138.5/-61.5+w24.5c/0.5c+v+o0.7/0i+ml  \
    --FONT_LABEL=12p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=10p,Helvetica,black \
    --MAP_TITLE_OFFSET=2.0c \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.2c \
    -Baf+l"Marine free-air gravity anomaly: Bill Haxby's color scheme for geoid & gravity [C=RGB]" \
    -I0.2 -By+lmGal \
    -UBL/-5p/-40p -O -K >> $ps
    
# Step-10. Add projection scale
gmt psbasemap -R -J \
    --FONT=12p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx13c/-1.7c+c50+w800k+l"Oblique Mercator projection. Scale (km)"+f \
    -O -K >> $ps
    
# texts
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica,black+jLB -Gwhite@10 >> $ps << EOF
176.2 -36.3 North
176.2 -37.0 Island
171.7 -45 South
171.7 -45.7 Island
159.3 -55 Macquarie Island
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
159 -55 0.2c
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,Helvetica−Bold,black+jLB+a-300 -Gwhite@10 >> $ps << EOF
161.2 -53 Macquarie Arc
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,Times-Roman,black+jLB -Gwhite@10 >> $ps << EOF
170 -50 CAMPBELL
170 -50.7 PLATEAU
175 -43.4 CHATHAM RISE
167 -39 CHALLENGER
167 -39.7 PLATEAU
161 -57 Hjort
161 -57.7 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,Helvetica−Bold,darkblue+jLB -Gwhite@10 >> $ps << EOF
153.5 -38.5 T A S M A N  S E A
176.0 -52 P A C I F I C
176.0 -53 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,red+jLB+a-290 -Gwhite@10>> $ps << EOF
182 -36.2 Kermadec Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,Helvetica−Bold,red+jLB+a-304 -Gwhite@10>> $ps << EOF
177.5 -42.0 Hikurangi Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,Helvetica−Bold,red+jLB+a-300 -Gwhite@10>> $ps << EOF
158.5 -53.0 P u y s e g u r  T r e n c h
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,Helvetica−Bold,red+jLB+a-110 -Gwhite@10>> $ps << EOF
159 -56.0 Hjort
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,Helvetica−Bold,red+jLB+a-56 -Gwhite@10>> $ps << EOF
158.2 -58.0 Trench
EOF

# Add logo
gmt logo -Dx6.5/-2.3+o0.1i/0.1i+w2c -O -K >> $ps
# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y15.5c -N -O \
    -F+f13p,Helvetica−Bold,black+jLB >> $ps << EOF
0.0 16.4 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
0.0 15.7 Oblique Mercator projection (-JOc) parameters: center 165\232/-29.5\232; pole -100\232/85\232.
EOF
# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_PHT.ps -A1.5c -E720 -Tj -P -Z

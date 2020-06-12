#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: New Zealand, Hikurangi, Puysegur and Hjort trenches).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert
# Step-1. Generate a file
ps=Grav_PHT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinner,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    MAP_ANNOT_OFFSET=0.1c \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    MAP_LABEL_OFFSET=0.1c
# Step-3. Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R145/186/-62/-30 -Ggrav.grd -T1 -I1 -E -S0.1 -V
# Step-4. Generate a color palette table from grid
gmt grd2cpt grav.grd -Crainbow > grav.cpt
# Step-5. Generate gravity image with shading
gmt grdimage grav.grd -I+a45+nt1 -R145/186/-62/-30 -JM16c -Cgrav.cpt -P -K > $ps
# Step-6. Add basemap: grid, title, costline
gmt pscoast -R -J -P \
	-V -W0.25p -Df \
    -B+t"Marine free-air gravity anomaly: New Zealand, Hikurangi, Puysegur and Hjort trenches" \
	-Bxg10f5a10 -Byg5f2.5a5 \
    -O -K >> $ps
# Step-8. Add color legend
gmt psscale -R -J -Cgrav.cpt \
    -Dg138.5/-62+w18.3c/0.5c+v+o0.7/0i+ml  \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.1c \
    -Baf+l"Marine free-air gravity anomaly color scale" \
    -I0.2 -By+lmGal \
    -UBL/-5p/-40p -O -K >> $ps
# Step-10. Add projection scale
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx14c/-0.5i+c50+w800k+l"Mercator projection. Scale (km)"+f \
    -O -K >> $ps
# texts
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,black+jLB -Gwhite@20 >> $ps << EOF
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
-F+f10p,Helvetica−Bold,black+jLB+a-310 -Gwhite@30 >> $ps << EOF
161.2 -53 Macquarie Arc
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,black+jLB -Gwhite@20 >> $ps << EOF
170 -50 CAMPBELL
170 -50.7 PLATEAU
175 -43.4 CHATHAM RISE
167 -39 CHALLENGER
167 -39.7 PLATEAU
161 -57 Hjort
161 -57.7 Plateau
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,white+jLB >> $ps << EOF
153.5 -38.5 T A S M A N  S E A
178 -52 P A C I F I C
178 -53 O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,red+jLB+a-299 -Gwhite@30>> $ps << EOF
182 -36.2 Kermadec Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,red+jLB+a-304 -Gwhite@30>> $ps << EOF
177.5 -42.0 Hikurangi Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,red+jLB+a-308 -Gwhite@30>> $ps << EOF
158.5 -53.0 P u y s e g u r  T r e n c h
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,red+jLB+a-110 -Gwhite@30>> $ps << EOF
159 -56.0 Hjort
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,red+jLB+a-56 -Gwhite@30>> $ps << EOF
158.2 -58.0 Trench
EOF
# Step-11. Add logo
gmt logo -Dx6.5/-2.0+o0.1i/0.1i+w2c -O -K >> $ps
# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.5 15.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
EOF
# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_PHT.ps -A0.5c -E720 -Tj -P -Z

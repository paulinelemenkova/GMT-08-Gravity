#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: Vityaz and Vanuatu trenches).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert
# Step-1. Generate a file
ps=Grav_VVT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinner,white \
#    MAP_GRID_CROSS_SIZE_PRIMARY=1.0c \
    MAP_ANNOT_OFFSET=0.1c \
    FONT_TITLE=14p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    MAP_LABEL_OFFSET=0.1c
# Step-3. Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R145/200/-39/0 -Ggrav.grd -T1 -I1 -E -S0.1 -V
# Step-4. Generate a color palette table from grid
gmt grd2cpt grav.grd -Crainbow > grav.cpt
# Step-5. Generate gravity image with shading
#gmt grdimage grav.grd -I+a45+nt1 -R145/200/-39/0 -JM16c -Cgrav.cpt -P -K > $ps
gmt grdimage grav.grd -I+a45+nt1 -R145/200/-39/0 -JCyl_stere/170/-20/16c -Cgrav.cpt -P -K > $ps
# Step-6. Add basemap: grid, title, costline
gmt pscoast -R -J -P \
	-V -W0.25p -Df \
    -B+t"Marine free-air gravity anomaly: Fiji region, Vityaz and Vanuatu trenches" \
	-Bxg10f5a10 -Byg10f5a10 \
    -O -K >> $ps
# Step-7. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=9p,Helvetica,dimgray \
    --MAP_ANNOT_OFFSET=0.2c \
-Lx13.0c/-1.3c+c50+w1000k+l"Cylindrical Stereographic projection, scale km"+f \
    -UBL/-5p/-40p -O -K >> $ps
# Step-8. Add legend
gmt psscale -R -J -Cgrav.cpt \
    -Dg135/-39+w12.3c/0.5c+v+o0.7/0i+ml  \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.1c \
    -Baf+l"Marine free-air gravity anomaly color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
# texts
gmt pstext -R -J -N -O -K \
-F+f9p,Times-Roman,black+jLB -Gwhite@20 -Wthinnest,darkbrown >> $ps << EOF
175 -38.5 NEW ZEALAND
145.3 -28.0 AUSTRALIA
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,Helvetica−Bold,gold+jLB -Gdimgray@30>> $ps << EOF
149.5 -13.5 C O R A L
152.2 -15.5 S E A
175.0 -3.5 P A C I F I C   O C E A N
185.2 -9.2
172.5 -25.5 F I J I  S E A
152.5 -38.5 T A S M A N  S E A
EOF
# gmt psxy -R -J trench.gmt -Sf1.5c/0.2c+l+t -Wthick,yellow -Gyellow -O -K >> $ps
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,white+jLB+a-290 >> $ps << EOF
181.5 -36 Kermadec Trench
185.6 -24 Tonga Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,red+jLB+a-32 -Gwhite@30>> $ps << EOF
168 -7.5 Vityaz Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,red+jLB+a-72 -Gwhite@40 >> $ps << EOF
166.8 -10.5 V a n u a t u  T r e n c h
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
176.0 -19.2 FIJI
189.0 -13.8 SAMOA
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Times-Roman,black+jLB+a-39 -Gwhite@30 >> $ps << EOF
164 -19.1 New Caledonia
EOF
# Step-14. Add text
gmt pstext -R -J -N -O -K \
-F+f8p,Helvetica,dimgray+jLB >> $ps << END
181.5 -45.0 Central meridian/standard parallel: 170\232/-20\232
END
# Step-0. Add logo
gmt logo -R -J -Dx6.5/-2.0+o0.1i/0.1i+w2c -O -K >> $ps
# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y3.2c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.5 15.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
EOF
# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_VVT.ps -A0.2c -E720 -Tj -P -Z

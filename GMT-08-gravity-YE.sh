#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Yemen)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

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
    FONT_ANNOT_PRIMARY=7p,0,dimgray \
    FONT_LABEL=7p,0,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract subset of img file in Mercator or Geographic format
gmt img2grd grav_27.1.img -R42/55/10/20 -Ggrav.grd -T1 -I1 -E -S0.1 -V
gmt grdcut grav.grd -R42/55/10/20 -Gye_grav.nc
gdalinfo -stats ye_grav.nc
# Minimum=-139.232, Maximum=286.200
gmt makecpt -Cturbo -T-139/286/1 > colors.cpt
# gmt makecpt --help

ps=Grav_YE.ps
# Make raster image
gmt grdimage ye_grav.nc -Ccolors.cpt -R42/55/10/20 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg40.5/10.0+w13.0c/0.15i+v+o0.3/0i+ml -R -J -Ccolors.cpt \
	--FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg50f10a50+l"Color scale 'turbo': Google's Improved Rainbow Colormap for Visualization [C=RGB] -162/418)" \
	-I0.2 -By+lmGal -O -K >> $ps
    
# Add isolines
gmt grdcontour ye_grav.nc -R -J -C25 -Wthinnest -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,13,black \
    -Bpxg4f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Free-air gravity anomaly for Yemen" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.3c+c50+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-38p -O -K >> $ps

gmt psbasemap -R -J \
    --FONT_TITLE=7p,0,white \
    --MAP_TITLE_OFFSET=0.1c \
    -Tdx1.0c/0.4c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,red+jLB+a-340 >> $ps << EOF
53.0 17.8 O    M    A    N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,red+jLB+a-340 >> $ps << EOF
46.1 17.8 S  A  U  D  I     A  R  A  B  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,red+jLB+a-330 -Gwhite@30 >> $ps << EOF
42.1 11.5 DJIBOUTI
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,red+jLB+a-350 -Gwhite@60 >> $ps << EOF
47.0 10.3 S   O   M   A   L   I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,25,purple4+jLB+a-340 >> $ps << EOF
46.3 15.9 Y        E        M        E        N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,red+jLB+a-50 -Gwhite@30 >> $ps << EOF
42.0 13.4 ERITREA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,25,red+jLB+a-60 -Gwhite@30 >> $ps << EOF
42.0 10.9 ETHIOPIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,13,blue+jLB+a-340 -Gwhite@60 >> $ps << EOF
46.5 11.6 G u l f   o f   A d e n
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,royalblue4+jLB -Gwhite@50 >> $ps << EOF
53.4 15.5 Arabian
53.7 15.1 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,royalblue4+jLB -Gwhite@50 >> $ps << EOF
53.7 10.8 Indian
53.6 10.4 Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-60 -Gwhite@70 >> $ps << EOF
42.9 13.4 Bab-el-Mandeb
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,chocolate4+jLB+a-340 >> $ps << EOF
46.1 18.7 A R   R U B'  A L  K H A L I
46.5 18.5 (Empty Quarter Desert)
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB+a-82 -Gwhite@70 >> $ps << EOF
42.2 16.5 R e d   S e a
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,brown4+jLB -Gwhite@30 >> $ps << EOF
53.5 12.0 Socotra
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,13,darkbrown+jLB+a-345 -Gwhite@70 >> $ps << EOF
47.7 15.1 H A D H R A M A U T
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,darkorchid4+jLB+a-18 >> $ps << EOF
51.0 17.1 Jabal Mahra
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,darkorchid4+jLB >> $ps << EOF
50.1 16.8 Jabal Bin
50.1 16.5 Kushayt
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,darkorchid4+jLB+a-45 >> $ps << EOF
44.6 17.3 Ramlat Dahm
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,darkorchid4+jLB+a-330 >> $ps << EOF
46.4 15.3 Ramlat
46.4 15.0 al-Sab'atayn
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,darkorchid4+jLB >> $ps << EOF
43.3 15.2 Jabal
43.3 14.9 Haraz
EOF
# cities
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.2 15.4 Sana'a
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
44.1 15.2 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
45.1 13.1 Aden
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
45.0 13.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.2 13.2 Taiz
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.0 13.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
43.1 14.6 Al Hudaydah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.0 14.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.2 13.7 Ibb
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.1 13.6 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
49.1 14.4 Al Mukalla
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
49.0 14.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.3 14.4 Dhamar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.2 14.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
43.3 15.6 Amran
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.6 15.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
43.5 16.7 Sadah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.4 16.6 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
52.2 16.2 Al Ghaydah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
52.1 16.1 0.20c
EOF

# Add GMT logo
gmt logo -Dx7.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y8.0c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
3.0 9.0 Global satellite derived gravity grid (CryoSat-2 and Jason-1).
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_YE.ps -A0.2c -E720 -Tj -Z

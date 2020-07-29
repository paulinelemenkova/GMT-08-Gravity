#!/bin/sh
# Purpose: sediment thickness (here: North Sea, Atlantic Ocean)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, pscoast, pstext, gmtlogo, psconvert

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

# Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R-7/15/50/63 -GgravNS.grd -T1 -I1 -E -S0.1 -V

gdalinfo gravNS.grd -stats
# Minimum=-77.590, Maximum=200.011

# Select a color palette
#gmt makecpt -Chaxby.cpt -V -T-78/201/1 > colors.cpt
gmt makecpt -Chaxby.cpt -V -T-78/100/1 > colors.cpt

# Generate a file
ps=Grav_NS.ps

# Make raster image
gmt grdimage gravNS.grd -Ccolors.cpt -R-7/15/50/63 -JU31/5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_TITLE_OFFSET=0.7c \
    --MAP_FRAME_AXES=WESN \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_LABEL=8p,Helvetica,black \
    -Bpxg4f2a4 -Bpyg8f4a2 -Bsxg2 -Bsyg2 \
    -B+t"Marine free-air gravity anomaly: North Sea, Atlantic Ocean" -O -K >> $ps
    
# Add shorelines
gmt grdcontour gravNS.grd -R -J -C50 -Wthinner,dimgray -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinner,blue -Na -N1/thin,red -Wthin -Df -O -K >> $ps

# Add scale
gmt psbasemap -R -J \
    --MAP_TITLE_OFFSET=0.1c \
    --FONT_LABEL=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    -Lx12.0c/-2.8c+c50+w500k+l"UTM projection, zone 31. Scale: km"+f \
    -UBL/-5p/-80p -O -K >> $ps

# Add legend
gmt psscale -Dg-7/48+w14.0c/0.4c+h+o0.3/0i+ml -R -J -Ccolors.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Bg100f10a20+l"Color scale: Bill Haxby's color scheme for gravity [C=RGB, actual range -77.590/200.011 mGal])" \
    -I0.2 -By+lmGal -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Helvetica,brown+jLB -Gwhite@40 >> $ps << EOF
6.1 50.9 Luxemburg
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,brown+jLB -Gwhite@40 >> $ps << EOF
8.2 56.2 DENMARK
6.5 61 NORWAY
-3.5 55 UNITED
-3.5 52.5 K I N G D O M
3.3 50.7 BELGIUM
1.8 50.1 FRANCE
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,brown+jLB+a-355 -Gwhite@40 >> $ps << EOF
9.5 51 GERMANY
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Helvetica,brown+jLB+a-315 -Gwhite@40 >> $ps << EOF
4.5 51.5 NETHERLANDS
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Helvetica,brown+jLB+a-355 -Gwhite@40 >> $ps << EOF
12.1 59 SWEDEN
EOF

# Add GMT logo
gmt logo -Dx6.0/-3.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.2 13.6 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
1.7 13.0 Universal Transverse Mercator zone 31, central meridian 4\232E
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_NS.ps -A0.8c -E720 -Tj -Z

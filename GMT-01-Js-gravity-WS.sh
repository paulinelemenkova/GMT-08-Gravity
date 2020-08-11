#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1/GEBCO datasets (here: Weddell Sea)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# Step-2. GMT set up
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
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R290/360/-80/-40 -Ggrav.grd -T1 -I1 -E -S0.1 -V
grdcut grav.grd -R290/360/-80/-60 -Gws_grav.nc

gdalinfo ws_grav.nc -stats
# Minimum=-309.888, Maximum=273.712
# Make color palette
# gmt makecpt -Chaxby.cpt -V -T-310/274/10 > colors.cpt
gmt makecpt -Chaxby.cpt -V -T-200/200/10 > colors.cpt

# Generate a file
ps=Grav_WS.ps
gmt grdimage ws_grav.nc -Ccolors.cpt -R290/360/-80/-60 -Js325/-90/5.5i/-60 -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a10 -Bpyg10f2.5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.3c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -B+t"Marine free-air gravity anomaly: Weddell Sea" \
    -Lx10.7c/-3.0c+c318/-57+w1000k+l"Polar stereographic projection"+f \
    -UBL/2.8c/-85p -O -K >> $ps

# Add shorelines
# gmt grdcontour ws_grav.nc -R -J -C100 -W0.1p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,blue+jLB >> $ps << EOF
318 -67.0 W E D D E L L
322 -68.5 S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,black+jLB -Gwhite@40 >> $ps << EOF
291 -67.0 Antarctic
290 -67.8 Peninsula
EOF

gmt psscale -R -J -Ccolors.cpt\
    -DjBC+o0.0c/-3.1c+w10c/0.5c+h\
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    -Bg50f50a25++l"Color scale 'haxby': B. Haxby's color scheme for geoid & gravity [R=-310/274/10, C=RGB]" \
    -I0.2 -By+lmGal -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.6/-1.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y4.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.8 10.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
1.0 9.3 Polar stereographic conformal projection. Central meridian 35\232W, standard parallel 60\232S
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_WS.ps -A1.0c -E720 -Tj -Z

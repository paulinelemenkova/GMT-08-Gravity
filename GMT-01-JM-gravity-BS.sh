#!/bin/sh
# Purpose: Gravity model map (here: Beaufort Sea, Arctic Ocean)
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
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R180/270/60/80 -Ggrav.grd -T1 -I1 -E -S0.1 -V

gdalinfo grav.grd -stats
# Minimum=-155.097, Maximum=366.939

# Select a color palette
gmt makecpt -Chaxby.cpt -V -T-106/85/1 > colors.cpt

# Generate a file
ps=Grav_BS.ps

# Make raster image
gmt grdimage grav.grd -I+a45+nt1 -R180/270/60/80 -JM5.5i -Ccolors.cpt -P -K > $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_TITLE_OFFSET=0.7c \
    --MAP_FRAME_AXES=wESN \
    -Bpxg10f5a10 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=6p,Helvetica,black \
    -B+t"Marine free-air gravity anomaly: Beaufort Sea, Arctic Ocean" -O -K >> $ps
    
# Add shorelines
gmt grdcontour grav.grd -R -J -C100 -Wthinneк,dimgray -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -W0.2p -Df -O -K >> $ps
    
# Add scale
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx12.0c/-1.3c+c50+w2000k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add legend
gmt psscale -Dg169/60.0+w10.0c/0.4c+v+o0.3/0i+ml -R -J -Ccolors.cpt \
    --FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -B10f2+l"Color scale: Haxby: Bill Haxby's color scheme for geoid & gravity [C=RGB])" \
    -I0.2 -By+lmGal -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,blue+jLB >> $ps << EOF
210.2 79.5 A R C T I C    O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,blue+jLB >> $ps << EOF
209.7 76.5 B E A U F O R T
216.0 75.5 S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Palatino-Italic,blue+jLB+a-55 >> $ps << EOF
227.0 68.6 Mackenzie
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Palatino-Italic,blue+jLB+a-60 >> $ps << EOF
234.8 68.5 Anderson
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Palatino-Roman,black+jLB -Gwhite@40 >> $ps << EOF
240.5 77.0 Queen
240.7 76.4 Elizabeth
240.9 75.7 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Palatino-Roman,black+jLB -Gwhite@40 >> $ps << EOF
246 71.0 Victoria
246.5 70.3 Island
235.3 73.0 Banks
235.6 72.3 Island
EOF

# Add GMT logo
gmt logo -Dx6.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.5 7.5 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_BS.ps -A0.5c -E720 -Tj -Z

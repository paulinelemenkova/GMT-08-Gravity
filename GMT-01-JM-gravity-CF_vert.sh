#!/bin/sh
# Purpose: free-air gravity anomalies of Bolivia
# GMT modules: gmtset, gmtdefaults, img2grd, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert, pscoast

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

# Convert file from IMG format to GRD format
gmt img2grd curv_27.1.img -R14/28/2/11.5 -Ggravvert_CF.grd -T1 -I1 -E -S0.1 -V
# Check statistics
gdalinfo gravvert_CF.grd -stats
# Minimum=-100.418, Maximum=116.835, Mean=-0.126, StdDev=8.658

# Generate a color palette table from grid
# gmt makecpt -Chaxby.cpt -T-40/40 > colors.cpt
gmt makecpt -Cmag.cpt -T-40/40 > colors.cpt
# gmt makecpt --help

# Generate a file
ps=Grav_CF_vert.ps

gmt grdimage gravvert_CF.grd -Ccolors.cpt -R14/28/2/11.5 -JM6.0i -P -I+a15+ne0.75 -Xc -K > $ps

# Add isolines
gmt grdcontour gravvert_CF.grd -R -J -C20 -A40 -Wthinner -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx4f2a2 -Bpyg4f2a2 -Bsxg2 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,25,black \
    -B+t"Vertical gravity gradient over Central African Republic" -O -K >> $ps
    
# Add legend
gmt psscale -Dg14/1+w15.0c/0.15i+h+o0.3/0i+ml+e -R -J -Ccolors.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=8p,25,black \
    -Bg20f1a10+l"Color scale 'mag' [C=RGB] -T-40/40]" \
    -I0.2 -By+l"mGal" -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx13.5c/-2.3c+c50+w300k+l"Mercator projection. Scale: km"+f \
    -UBL/-0p/-70p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thickest,deeppink1 -Wthin,darkslategray -Df -O -K >> $ps

# Texts

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.0c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
2.3 9.2 IGPP Global Earth Free-Air Anomaly, 0.025 mGal resolution
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_CF_vert.ps -A0.5c -E720 -Tj -Z

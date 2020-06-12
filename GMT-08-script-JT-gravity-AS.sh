#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: Indian Ocean).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,gray30 \
    MAP_GRID_CROSS_SIZE_PRIMARY=0.5c \
    MAP_ANNOT_OFFSET=0.1c \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    MAP_LABEL_OFFSET=0.1c
    
# Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R47/77/0/31 -Ggrav.grd -T1 -I1 -E -S0.1 -V

grdcut grav.grd -R47/77/0/31 -Gas_grav.nc

# Generate a color palette table from grid
gdalinfo as_grav.nc -stats
#Minimum=-155.097, Maximum=366.939
# gmt grd2cpt grav.grd -Crainbow > grav.cpt
gmt makecpt -Chaxby.cpt -V -T-155/366/10 > colors.cpt

# Step-1. Generate a file
ps=Grav_AS.ps
# Generate gravity image with shading
gmt grdimage grav.grd -I+a45+nt1 -R47/77/0/31 -JT62/15/6i -Ccolors.cpt -P -K > $ps

# Step-6. Add basemap: grid, title, coastline
#gmt psbasemap -R -J \
 #   -Bpx104f5a5 -Bpyg10f5a5 -Bsxg2.5 -Bsyg2.5 \
  #  --MAP_TITLE_OFFSET=0.8c \
   # -B+t"Marine free-air gravity anomaly: Arabian Sea region" -O -K >> $ps
gmt pscoast -R -J -P \
    -V -W0.25p \
    -Df -B+t"Marine free-air gravity anomaly: Arabian Sea region" \
    --MAP_TITLE_OFFSET=0.8c \
    -Bpx104f2.5a5 -Bpyg10f2.5a5 -Bsxg2.5 -Bsyg2.5 \
    -O -K >> $ps

gmt grdcontour grav.grd -R -J -C30 -W0.1p -O -K >> $ps

# Step-7. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx12.6c/14.0c+w0.3i+f2+l+o0.15i \
    -Lx12c/-2.5c+c50+w800k+l"Transverse Mercator projection. Scale: km"+f \
    -UBL/-5p/-70p -O -K >> $ps
    
# Step-8. Add legend
gmt psscale -Dg47/-2.6+w15.0c/0.4c+h+o0.3/0i+ml -R47/77/0/31 -J -Ccolors.cpt \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Ba10f2+l"Color scale: Haxby: Bill Haxby's color scheme for geoid & gravity [C=RGB]" \
    -I0.2 -By+lmGal -O -K >> $ps
    
# Add GMT logo
gmt logo -Dx6.2/-3.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.0 15.1 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
1.7 14.6 Transverse Mercator prj. Central meridian: 62\232E Standard parallel: 15\232N
EOF

# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_AS.ps -A0.5c -E720 -Tj -P -Z

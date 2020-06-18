#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Cascadia Trench)
# GMT modules: gmtset, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

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
FONT_LABEL=7p,Helvetica,dimgray \

# Extract subset of img file in Mercator or Geographic format
#img2grd Und_min1x1_egm2008_isw_82_WGS84_TideFree.img -R224/240/35/55 -Ggrav.grd -T1 -I1 -E -S0.1 -V
#xyz2grd Und_min1x1_egm2008_isw_82_WGS84_TideFree -Ggrav1.grd -R224/240/35/55 -I30c -N-9999 -V -F -ZTLh
#xyz2grd Und_min1x1_egm2008_isw_82_WGS84_TideFree.pgm -Ggrav1.grd -R224/240/35/55 -I30c -V -ZTLh

img2grd grav_27.1.img -R224/240/35/55 -Ggrav.grd -T1 -I1 -E -S0.1 -V
grdcut grav.grd -R224/240/35/55 -Gct_grav.nc

gdalinfo ct_grav.nc -stats
#Minimum=-177.328, Maximum=216.119

# Make color palette
gmt makecpt -Chaxby.cpt -V -T-178/217/10 > colors.cpt

# Generate a file
ps=GravCT.ps
# Make raster image
gmt grdimage ct_grav.nc -Ccolors.cpt -R224/240/35/55 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg8f2a4 -Bpyg6f2a2 -Bsxg4 -Bsyg2 \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,dimgray \
    --MAP_ANNOT_OFFSET=0.1c \
    -B+t"Marine free-air gravity anomaly: Cascadia Trench" -O -K >> $ps
    
# Add legend
gmt psscale -Dg217/35+w15.0c/0.4c+h+o7.0/-1.5c+ml -Rct_relief.nc -J -Ccolors.cpt \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
    -Baf+l"Color scale: haxby (B. Haxby's color scheme for geoid & gravity [C=RGB] -177.328/216.119)" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour ct_grav.nc -R -J -C30 -A15 -Wthinnest,dimgray -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/1.3c+w0.3i+f2+l+o0.15i \
    -Lx13.4c/-2.7c+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-75p -O -K >> $ps
    
# Add GMT logo
gmt logo -Dx6.4/-3.5+o0.1i/0.1i+w2c -O -K >> $ps


# Add subtitle
gmt pstext -R0/10/0/15 -JX10/14 -X0.5c -Y7.1c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 22.5 Global gravity grid EGM96, CryoSat-2 and Jason-1
EOF

# Convert to image file using GhostScript
gmt psconvert GravCT.ps -A2.5c -E720 -Tj -Z

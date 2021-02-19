#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mongolia)
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
gmt img2grd curv_27.1.img -R87.5/120/41.5/52.5 -Ggrav_v.grd -T1 -I1 -E -S0.1 -V
gmt grdcut grav_v.grd -R87.5/120/41.5/52.5 -Gmn_grav_v.nc
gdalinfo -stats mn_grav_v.nc
# Minimum=-275.589, Maximum=490.174, Mean=-0.314, StdDev=39.126
#gmt makecpt -Chaxby -T-234/393/1 > colors.cpt
gmt makecpt -Chaxby -T-150/150/1 > pauline.cpt
# gmt makecpt --help


#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R87.5/120/41.5/52.5 -JM6.5i -Dh -M -EMN > Mongolia.txt
#gmt pscoast -Dh -M -ELB > Malawi.txt
#####################################################################

ps=Grav_MN_vert.ps
# Make background transparent image
gmt grdimage mn_grav_v.nc -Cpauline.cpt -R87.5/120/41.5/52.5 -JM6.5i -I+a15+ne0.75 -t100 -Xc -P -K > $ps
    
# Add isolines
#gmt grdcontour mn_grav_v.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
#gmt psclip -JM -R Malawi.txt -O -K >> $ps

gmt psclip -R87.5/120/41.5/52.5 -JM6.5i Mongolia.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage mn_grav_v.nc -Cpauline.cpt -R87.5/120/41.5/52.5 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour mn_grav_v.nc -R -J -C250 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg87.2/39.6+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg20f2a20+l"Colormap: 'haxby' (Bill Haxby's color scheme for geoid & gravity [C=RGB] -150/150/1)" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_GRID_PEN_PRIMARY=thinner,grey \
    --MAP_GRID_PEN_SECONDARY=thinnest,grey \
    -Bpxg10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=16p,13,black \
    -B+t"Vertical free-air gravity anomaly for Mongolia" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-2.5c+c10+w1000k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Texts

# Add GMT logo
gmt logo -Dx7.0/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y2.9c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
3.1 9.0 Global satellite derived gravity grid (CryoSat-2 and Jason-1)
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_MN_vert.ps -A0.5c -E720 -Tj -Z

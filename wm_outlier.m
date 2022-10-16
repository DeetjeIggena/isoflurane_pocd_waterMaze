% function returns the relative amount of coordinates spent outside the
% goal directed corridor (predefined by phi)

% input: x & y coordinates (normalized), gx = x-coordinates of goal location,
%        gy = y-coordinates of goal location, phi = angle toward goal
% output: percentage of coordinates outside the corridor

function outlier = wm_outlier(x,y,gx,gy,phi)

rows_real = length(x);

j = 1; i = 1;
outliers = 0;

if i==1
    fstx(1)=x(1);
    fsty(1)=y(1);
    nGOALX=gx-fstx;
    nGOALY=gy-fsty;
    while j<rows_real+1
        if i==1
            %constructing the angle
            px1=(nGOALX*cosd(phi)+nGOALY*sind(phi));
            py1=(-nGOALX*sind(phi)+nGOALY*cosd(phi));
            px2=(nGOALX*cosd(-phi)+nGOALY*sind(-phi));
            py2=(-nGOALX*sind(-phi)+nGOALY*cosd(-phi));
            d1=sqrt((nGOALX-0).^2+(nGOALY-0).^2);
            d2=sqrt((nGOALX-0).^2+(nGOALY-d1).^2);
            %calculating gamma for POSITIVE x-coordinates
            if fstx<0.5
                gamma=acosd((d1^2+d1^2-d2^2)/(2*d1*d1));
                %bringing coordinates of P1 and P2 back to normal coordinate-system
                %(not relative to starting-point)
                px1g=px1+fstx;
                py1g=py1+fsty;
                px2g=px2+fstx;
                py2g=py2+fsty;
                px1r=px1*cosd(360-gamma)+py1*sind(360-gamma);
                py1r=-px1*sind(360-gamma)+py1*cosd(360-gamma);
                px2r=px2*cosd(360-gamma)+py2*sind(360-gamma);
                py2r=-px2*sind(360-gamma)+py2*cosd(360-gamma);
                %calculating the slope
                mp1=py1r/px1r;
                mp2=py2r/px2r;
                i=0;
                %calculating gamma for NEGATIVE x-coordinates
            else
                gamma=acosd((d1.^2+d1.^2-d2.^2)/(2.*d1.*d1));
                px1g=px1+fstx;
                py1g=py1+fsty;
                px2g=px2+fstx;
                py2g=py2+fsty;
                px1r=px1.*cosd(gamma)+py1.*sind(gamma);
                py1r=-px1.*sind(gamma)+py1.*cosd(gamma);
                px2r=px2.*cosd(gamma)+py2.*sind(gamma);
                py2r=-px2.*sind(gamma)+py2.*cosd(gamma);
                mp1=-py1r/-px1r;
                mp2=-py2r/-px2r;
                i=0;
            end
        end
        px1rg=px1r+fstx;
        py1rg=py1r+fsty;
        px2rg=px2r+fstx;
        py2rg=py2r+fsty;
        movedxpos(j)=x(j)-fstx;
        movedypos(j)=y(j)-fsty;
        %rotation by gamma
        if fstx<0.5
            movedxpos2(j)=movedxpos(j)*cosd(360-gamma)+movedypos(j)*sind(360-gamma);
            movedypos2(j)=-movedxpos(j)*sind(360-gamma)+movedypos(j)*cosd(360-gamma);
        else
            movedxpos2(j)=movedxpos(j)*cosd(gamma)+movedypos(j)*sind(gamma);
            movedypos2(j)=-movedxpos(j)*sind(gamma)+movedypos(j)*cosd(gamma);
        end
        %calculating y-values on the angle borders
        yp1(j)=(mp1*movedxpos2(j));
        yp2(j)=(mp2*movedxpos2(j));
        if movedypos2(j)<yp1(j)
            outliers=outliers+1;
        else
        end
        if  movedypos2(j)<yp2(j)
            outliers=outliers+1;
        else
        end
        j=j+1;
    end
    outlier = (outliers/rows_real)*100;
end
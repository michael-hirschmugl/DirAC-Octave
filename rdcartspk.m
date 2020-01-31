function [azi, ele] = rdcartspk(filename)

% This script will read a file with a list of cartesian coordinates and convert 
% them into spherical coordinates.
% Intended to generate a speaker layout for ambisonics playback (or recording).

fid1 = fopen (filename, 'r');

i = 1;
index = 1;
row = 1;
lines = 0;

ix = 1;

fseek(fid1, 0, 'eof');
fileSize = ftell(fid1);
frewind(fid1);
data = fread(fid1, fileSize, 'uint8');
M = sum(data == 10) + 1;
frewind(fid1);

channels = M / 3;

%figure

ix = 1;
while (lines < M)
	matrix(ix,1) = str2double(fgetl(fid1));
	matrix(ix,2) = str2double(fgetl(fid1));
	matrix(ix,3) = str2double(fgetl(fid1));
	ix = ix + 1;
	lines = lines + 3;
end


fclose(fid1);

plot3(matrix(:,1),matrix(:,2),matrix(:,3),'^')

new_matrix = cart2sph(matrix);

ele = new_matrix(:,2) .* (180/pi);
azi = new_matrix(:,1) .* (180/pi);

[azi, ele]

dlmwrite("ls_dirs.txt", [azi, ele], ",");
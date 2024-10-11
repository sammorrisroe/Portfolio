clear; clc; close all;
%% Sam Morrisroe // Swarm Robotics Simulation // October 4, 2024 // Map Generation

% Idea is to create a tile map using matrices filled with either 0, 1, 2, or 3

% 0 corresponds to Ground
% 1 corresponds to Rocky Ground
% 2 corresponds to Rock
% 3 corresponds to Wet Ground


%% Create Map using chunk function

chunkSize = 8;
%Chunk Type A:
% Only Ground Tiles
minPercent1a = 0; % 0%
maxPercent1a = 0; % 0%
minPercent2a = 0; % 0%
maxPercent2a = 0; % 0%
minPercent3a = 0; % 0%
maxPercent3a = 0; % 0%

%Chunk Type B:
% Likely to Spawn Rocky Ground
% Moderately likely to spawn Rocks
% Unlikely to spawn wet ground
minPercent1b = 0.4; % 40%
maxPercent1b = 0.6; % 60%
minPercent2b = 0.0; % 0%
maxPercent2b = 0.05;% 5%
minPercent3b = 0.1; % 10%
maxPercent3b = 0.2; % 20%

%Chunk Type C:
% Unlikely to spawn rocky ground
% Moderately likely to spawn Rocks
% Moderately likely to spawn wet ground
minPercent1c = 0.1; % 10%
maxPercent1c = 0.2; % 20%
minPercent2c = 0.2; % 20%
maxPercent2c = 0.3;% 30%
minPercent3c = 0.2; % 20%
maxPercent3c = 0.4; % 40%

% Generate Map of 5 x 5 chunks
map = [];

for i = 1:5


    %Create horizontal map slices
    map_slice = [];

    for j = 1:5

        if i == 3 && j == 3

            % Chunk A
            chunk = GenerateChunk(chunkSize, minPercent1a, maxPercent1a, minPercent2a, maxPercent2a, minPercent3a, maxPercent3a);

        elseif i > 1 || i < 5 && j > 1 || j < 5

            % Chunk B
            chunk = GenerateChunk(chunkSize, minPercent1b, maxPercent1b, minPercent2b, maxPercent2b, minPercent3b, maxPercent3b);


        elseif i == 1 || i == 5 && j == 1 || j == 5

            % Chunk C
            chunk = GenerateChunk(chunkSize, minPercent1c, maxPercent1c, minPercent2c, maxPercent2c, minPercent3c, maxPercent3c);

        end

        map_slice = [map_slice,chunk];

        


    end

    map = [map; map_slice];


end

% Save the generated map to a text file to be read in Javascript simulation
fileID = fopen('output_map.txt', 'w'); % Open the file for writing
for i = 1:size(map, 1)
    fprintf(fileID, '%d ', map(i, :)); % Write each row
    fprintf(fileID, '\n'); % New line after each row
end
fclose(fileID); % Close the file


    



%% Generate Chunk Function

function chunk = GenerateChunk(chunkSize, minPercent1, maxPercent1, minPercent2, maxPercent2, minPercent3, maxPercent3)
    
        % INPUT:

        % chunkSize: width n x n chunk of zeros

        % minPercent1: the minimum percent of the given chunk that should be changed to 1
        % maxPercent1: the maximum percent of the given chunk that should be changed to 1

        % minPercent2: the minimum percent of the given chunk that should be changed to 2
        % maxPercent2: the maximum percent of the given chunk that should be changed to 2

        % minPercent3: the minimum percent of the given chunk that should be changed to 3
        % maxPercent3: the maximum percent of the given chunk that should be changed to 3

        % Chunk Starts as n x n matrix of zeros
        chunk = zeros(chunkSize,chunkSize);

        % Generate a random percentage within the the bounds of each percentage
        % NOTE: rand(1) generates a random number between 0 and 1
        percent1 = minPercent1 + (maxPercent1 - minPercent1) * rand(1);
        percent2 = minPercent2 + (maxPercent2 - minPercent2) * rand(1);
        percent3 = minPercent3 + (maxPercent3 - minPercent3) * rand(1);

        % Total number of tiles within chunk
        num_tiles_tot = chunkSize * chunkSize;

        % Using the total number of tiles within the chunk along with the
        % semi-randomly generated percentages we can get how many of each
        % tile to generate
        numTiles1 = round(num_tiles_tot * percent1);
        numTiles2 = round(num_tiles_tot * percent2);
        numTiles3 = round(num_tiles_tot * percent3);

        % Begin by generating rocky ground which is denoted by 1
        chunk = generateTiles(chunk, chunkSize, numTiles1, 1, 10);

        % Next by generating wet ground which is denoted by 2
        chunk = generateTiles(chunk, chunkSize, numTiles2, 2, 1);

        % Next by generating rock which is denoted by 3
        chunk = generateTiles(chunk, chunkSize, numTiles3, 3, 5);
        
      
end

%% Generate tiles within chunk

function chunk = generateTiles(chunk, chunkSize, numTiles,tile_number, lead_tile_consistency)

        %Begin by generating rocky ground which is denoted by 1
        
        % Determine number of lead tiles for rocky ground
        lead_tiles = ceil(numTiles/lead_tile_consistency); %for a certain amount of tiles of a certain typewe want at least 1 starting position


        %Store position of tiles changed to tile number in nx2 matrix
        position_tiles = [];

        currentNumTiles = 0;

        for i = 1:lead_tiles
            
            %Randomly generate x and y coord within chunk
            lead_x = ceil(chunkSize * rand(1));
            lead_y = ceil(chunkSize * rand(1));

            %Set tile at that position to tile_number
            chunk(lead_x, lead_y) = tile_number;

            %Store position
            position_tiles(i,1) = lead_x;
            position_tiles(i,2) = lead_y;

            %Adjust current number of tiles
            currentNumTiles = currentNumTiles + 1;

        end


        % Generate Tiles
        while currentNumTiles < numTiles

            %Based on the current ratio of current tile number to desired
            %tile number set percent chance for new tiles to form

            %newTilePercent: the percent chance of new tiles to form

            Tile1Ratio = currentNumTiles/numTiles;

            if Tile1Ratio < 0.2
                
                %In between 80% and 100%
                newTilePercent = 0.8 + (1 - 0.8) * rand(1);

            elseif 0.2 <= Tile1Ratio && Tile1Ratio < 0.4

                %In between 60% and 80%
                newTilePercent = 0.6 + (0.8 - 0.6) * rand(1);

            elseif 0.4 <= Tile1Ratio && Tile1Ratio < 0.6

                %In between 40% and 60%
                newTilePercent = 0.4 + (0.6 - 0.4) * rand(1);

            elseif 0.6 <= Tile1Ratio && Tile1Ratio < 0.8

                %In between 20% and 40%
                newTilePercent = 0.2 + (0.4 - 0.2) * rand(1);

            elseif 0.8 <= Tile1Ratio && Tile1Ratio < 1

                %In between 0% and 20%
                newTilePercent = 0 + (0.2 - 0) * rand(1);

            end

            %Iterate through each 1 tile changing its neighbors also to a 1
            %randomly based on given percentage

            for i = 1:length(position_tiles)

                % Current tile
                current_x = position_tiles(i,1);
                current_y = position_tiles(i,2);

                % Create list of surrounding tiles
                surrounding_tiles = [current_x+1, current_y; % right tile
                                     current_x-1, current_y; % left tile
                                     current_x, current_y+1; % above tile
                                     current_x, current_y-1]; % below tile

                % Iterate over surrounding tiles
                for j = 1:length(surrounding_tiles)

                    newTile_x = surrounding_tiles(j,1);
                    newTile_y = surrounding_tiles(j,2);

                    % Check if tile is in bound and is not already a one
                    if 1 <= newTile_x && newTile_x <= chunkSize && 1 <= newTile_y && newTile_y <= chunkSize
                        if chunk(newTile_x,newTile_y) ~= tile_number

                            % Change the current tile to 1 based on the
                            % percentage
                            if rand(1) < newTilePercent

                                % Add tile to the list of 1 tiles
                                position_tiles = [position_tiles; newTile_x, newTile_y];

                                % Update Chunk
                                chunk(newTile_x,newTile_y) = tile_number;
    
                                %Update number of tiles
                                currentNumTiles = currentNumTiles + 1;

                            end

                        end
                   
                    end

                end

            end
                           

        end

      
end





configFile;
figure;

% sampleData = getCSIData;
% fieldNames = fieldnames(sampleData);

LOG_DATA = {};

while true
  csiData = getCSIData;
  csiMatrix = csiData.csi_matrix;
  nr = csiData.nr;
  nc = csiData.nc;
  num_tones = csiData.num_tones;

  % check the correctness of the data
  csiMatrixSize = [nr, nc, num_tones];
  if ~all(csiMatrixSize)
    continue;
  end

  howManyTxToUse = NUM_OF_TX_ANTENNAS_TO_USE; % you can set this variable to limit the number of data from different tx antennas
  pdpMatrix = [];
  for i = 1:nr
    for j = 1:howManyTxToUse
      csiChannel = reshape(csiMatrix(i, j, :), [1, num_tones]);
      pdp = csi2pdp(csiChannel);
      pdpMatrix = [pdpMatrix; pdp];
    end
  end

  err = 0;

  if length(pdpMatrix)
    [pseudoSpectrum, freq] = pmusic(pdpMatrix', 1);

    dataAoA.data = pseudoSpectrum;
    dataAoA.range = [0 180];
    dataAoA.length = length(pseudoSpectrum);

    [plotData err] = plotAoA(dataAoA, PLOT_AOA_RADIUS, PLOT_AOA_RADIUS_SCALE);
    drawnow;
  end
  if err ~= 0
    return;
  end

  if length(LOG_PARA)
    csiData.ntxused = howManyTxToUse;
    csiData.pseudoSpectrum = pseudoSpectrum;
    csiData.freq = freq;
    csiData.maximaLocs = plotData.localMaximasLocations;
    LOG_DATA = [LOG_DATA, csiData];
  end
end

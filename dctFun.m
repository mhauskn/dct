# dctFun.m
# Demonstrates a Discrete Cosine Transformation applied to a 2D image.
# This code is not optimized for speed! Use at your own risk.
# All code is based on https://en.wikipedia.org/wiki/Discrete_cosine_transform
# Author: Matthew Hausknecht

# One-dimensional DCT-II 
function X = dct2(x)
  assert(size(x)(2) == 1)
  N = size(x)(1);
  a = ones(N,1) * [0:N-1];
  X = cos((a .+ (1/2)) .* (pi/N * a')) * x;
end

# Inverse of One-dimensional DCT-II
function R = dct2Inverse(X)
  R = dct3(X) * (2 / 10);
end

# One-dimensional DCT-III 
function X = dct3(x)
  assert(size(x)(2) == 1)
  N = size(x)(1);
  a = ones(N,1) * [0:N-1];
  b = cos((pi/N * a) .* (a' .+ (1/2)));
  b(:,1) = 1/2;
  X = b * x;
end

# Inverse of One-dimensional DCT-III
function R = dct3Inverse(X)
  R = dct2(X) * (2 / 10);
end

# Two-dimensional DCT-II
function X = dct2d(x)
  assert(size(x)(1) == size(x)(2))
  # Apply function to columns in x
  c = cell2mat(cellfun(@dct2, num2cell(x,1), "UniformOutput", false));
  # Apply function to the rows in c
  X = cell2mat(cellfun(@dct2, num2cell(c',1), "UniformOutput", false))';
end

# Inverse of two-dimensional DCT-II
function R = dct2dInverse(X)
  assert(size(X)(1) == size(X)(2))
  # Apply function to rows in x
  c = cell2mat(cellfun(@dct3, num2cell(X,1), "UniformOutput", false));
  # Apply function to the rows in c
  R = (4/(size(X)(1)*size(X)(1))) * cell2mat(cellfun(@dct3, num2cell(c',1), "UniformOutput", false))';
end

# Encode a 2D image block by block and apply a lossy round
# blockSize: The size of the 2d square block typically 8 or 16
# divisor: The gain applied to the DCT coefficients before the round (controls the loss)
function X = encodeImage(x, blockSize, divisor)
  X = zeros(size(x));
  for y=1:blockSize:size(x)(1)
    for col=1:blockSize:size(x)(2)
      X(y:y+blockSize-1,col:col+blockSize-1) = dct2d(x(y:y+blockSize-1,col:col+blockSize-1));
    end
  end
  X = round(X / divisor);
end

# Decode X, the encoded image
function R = decodeImage(X, blockSize, divisor)
  X = X * divisor;
  R = zeros(size(X));
  for y=1:blockSize:size(X)(1)
    for x=1:blockSize:size(X)(2)
      R(y:y+blockSize-1,x:x+blockSize-1) = dct2dInverse(X(y:y+blockSize-1,x:x+blockSize-1));
    end
  end
end

# Read the baboon image, encode it using dct2d, write a copy of the encoded image,
# then decode the image and write the decoded image. Lossy compression in this 
# case is not implemented as in JPEG, but rather is a simple division followed 
# by a round. The larger the divisor, the more the loss. 
blockSize = 16;
divisor = 2000;
x = double(imread("baboon.png"));
# Subtract 128 to put the data in range [-128,128] rather than [0,256]
x = x - 128;
X = encodeImage(x, blockSize, divisor);
encoded = uint8(X);
imwrite(encoded, "encoded.png", "png");
R = decodeImage(X, blockSize, divisor);
R = R + 128;
decoded = uint8(R);
imwrite(decoded, "decoded.png", "png")

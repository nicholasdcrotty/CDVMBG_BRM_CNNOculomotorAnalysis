#MOVE THIS TO 'dataForDownload' FOLDER WHEN DONE

#----- Custom functions - Linear algebra stuff! -----
crossProduct = function(vec1, vec2){#cross-product of two 2D vectors
  return(vec1[1]*vec2[2] - vec1[2]*vec2[1])
}

dotProduct = function(vec1, vec2){#dot-product of two 2D vectors
  return(sum(vec1*vec2))
}

vecNorm = function(vec){
  return(sqrt(sum(vec^2)))
}

rotatePlane = function(vec1, vec2){
  vec1Rel = vec1-origin
  vec2Rel = vec2-origin
  rotationAngle = acos(dotProduct(vec1Rel, vec2Rel) / (vecNorm(vec1Rel)*vecNorm(vec2Rel)))
  crossProd = crossProduct(vec1Rel, vec2Rel)
  if(crossProd < 0){#counterclockwise rotation
    rotationAngle = -rotationAngle
  }
  
  rotationMatrix = matrix(c(cos(rotationAngle), sin(rotationAngle),
                            -sin(rotationAngle), cos(rotationAngle)),
                          nrow = 2, ncol = 2, byrow = TRUE)
  return(rotationMatrix)
}


rotateAngle = function(vec1, vec2){
  vec1Rel = vec1-origin
  vec2Rel = vec2-origin
  rotationAngle = acos(dotProduct(vec1Rel, vec2Rel) / (vecNorm(vec1Rel)*vecNorm(vec2Rel)))
  crossProd = crossProduct(vec1Rel, vec2Rel)
  if(crossProd < 0){#counterclockwise rotation
    rotationAngle = -rotationAngle
  }
  
  return(rotationAngle)
}

pixToDVA = function(pix,axis,screenCM,viewingDist){ #axis is either
  i = -1
  if (axis=='x'){i=1}else if (axis=='y'){i=2}
  deg = (180/pi)* ( 2*atan( screenCM[i]/ (2* viewingDist) ) )
  dva = pix* (deg/screenRes[1])
  return(dva)
}
DVAtoPix = function(visanglex, visangley,screenCM,viewingDist){
  visang_rad = 2 * atan(screenCM[1]/2/viewingDist)
  visang_deg = visang_rad * (180/pi)
  pix_pervisang = screenRes[1] / visang_deg
  sizex = round(visanglex * pix_pervisang)
  sizey = round(visangley * pix_pervisang)
  return(c(sizex,sizey))
}


# Gaussian Kernel Function (normalized for the 2D case)
gaussian_kernel <- function(distance, h, normalize) { #ASSISTANCE FROM AI (GEMINI) WHEN GENERATING THIS FUNCTION
  # Normalize by (1 / (2 * pi * h^2)) for a proper density function, 
  # but often just the exponent part is used for relative density maps
  kernel = exp(-(distance^2) / (2 * h^2)) / (2 * pi * h^2)
    
  return(kernel)
}


gaussianKDE = function(df_points, resolution){ #ASSISTANCE FROM AI (GEMINI) WHEN GENERATING THIS FUNCTION
  avgSD = (sd(df_points$xPos)+sd(df_points$yPos))/2
  
  h_bandwidth <- (1.059 * avgSD * nrow(df_points)^(-1/5)) #Silverman's rule of thumb
  
  # Define the boundaries based on your data range, plus a buffer for the kernel influence
  x_range <- range(df_points$xPos)
  y_range <- range(df_points$yPos)
  
  # 2. Create the Grid Points (Centroids)
  x_grid <- seq(x_range[1] - h_bandwidth, x_range[2] + h_bandwidth, by = resolution)
  y_grid <- seq(y_range[1] - h_bandwidth, y_range[2] + h_bandwidth, by = resolution)
  grid_points <- expand.grid(X_grid = x_grid, Y_grid = y_grid)
  
  # Initialize a vector to hold the calculated weighted density for each grid cell
  grid_points$Density <- 0
  
  # 3. Main Calculation Loop
  # Iterate through every grid point (the location 's' where density is calculated)
  for (j in 1:nrow(grid_points)) {
    s_x <- grid_points[j, "X_grid"]
    s_y <- grid_points[j, "Y_grid"]
    
    # Calculate distance from grid point to all data points
    distances <- sqrt((df_points$xPos - s_x)^2 + (df_points$yPos - s_y)^2)
    
    # Apply the kernel and weight: K(distance) * weight (Metric)
    kernel_values <- gaussian_kernel(distances, h = h_bandwidth)
    weighted_contributions <- kernel_values * df_points$value
    
    # Sum the contributions to get the final density at the grid point 's'
    grid_points[j, "Density"] <- sum(weighted_contributions)
    print(j)
  }
  return(grid_points)
}


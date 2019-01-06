import pandas as pd
import sys
location = sys.argv[1]
data = pd.read_csv(location)
title = sys.argv[2]
scaling = int(sys.argv[3])
print(title, 
      "& $",
      round(data[ data["Max_Calculation_Time"] == 5 ]["Avg_Last_Minimum_Tourlength"]/scaling,2)[0],
      "~\pm~",
      round(data[ data["Max_Calculation_Time"] == 5 ]["StdDev_Last_Minimum_Tourlength"]/scaling,2)[0],
      "$ &",
      round(data[ data["Max_Calculation_Time"] == 5 ]["Min_Last_Minimum_Tourlength"]/scaling,2)[0],
      "&",
      int(round(data[ data["Max_Calculation_Time"] == 5 ]["Avg_Elapsed_Time"],0)[0]),
      "& $",
      round(data[ data["Max_Calculation_Time"] == 60 ]["Avg_Last_Minimum_Tourlength"]/scaling,2)[1],
      "~\pm~",
      round(data[ data["Max_Calculation_Time"] == 60 ]["StdDev_Last_Minimum_Tourlength"]/scaling,2)[1],
      "$ &",
      round(data[ data["Max_Calculation_Time"] == 60 ]["Min_Last_Minimum_Tourlength"]/scaling,2)[1],
      "&",
      int(round(data[ data["Max_Calculation_Time"] == 60 ]["Avg_Elapsed_Time"],0)[1]),
      "& $",
      round(data[ data["Max_Calculation_Time"] == 3600 ]["Avg_Last_Minimum_Tourlength"]/scaling,2)[2],
      "~\pm~",
      round(data[ data["Max_Calculation_Time"] == 3600 ]["StdDev_Last_Minimum_Tourlength"]/scaling,2)[2],
      "$ &",
      round(data[ data["Max_Calculation_Time"] == 3600 ]["Min_Last_Minimum_Tourlength"]/scaling,2)[2],
      "&",
      int(round(data[ data["Max_Calculation_Time"] == 3600 ]["Avg_Elapsed_Time"],0)[2]),
      "\\\\")      

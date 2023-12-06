#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double med(NumericVector x){
  while (x.length() > 2){
    x.erase(which_max(x));
    x.erase(which_min(x));
  }
  return mean(x);
}

// [[Rcpp::export]]
double mad(NumericVector x) {
  return med(abs(x - med(x)));
}

// [[Rcpp::export]]
NumericVector prepare_col_bicor(NumericVector x){
  NumericVector x_val (x.length());
  x_val = x;
  NumericVector u (x.length());
  NumericVector I_x (x.length());
  NumericVector w_x (x.length());
  NumericVector x_curly (x.length());
  double denom_x;
  double med_x;
  
  med_x = med(x);

  u = (x - med_x) / ( 9 * mad(x));
  //Rcout << "u: " << u << '\n';
  I_x = ifelse((1-abs(u)) > 0, 1, 0);
  //Rcout << "I_x: " << I_x << '\n';
  w_x = pow((1-u*u), 2) * I_x;// * (1 - u.length());
  //Rcout << "w_x: "<< w_x << '\n';
  denom_x = sqrt(sum(pow((x - med_x) * w_x, 2)));
  //Rcout << "denom_x: "<< denom_x << '\n';
  x_curly = ((x - med_x) * w_x) / denom_x;
  //Rcout << "x_curly: "<< x_curly << '\n';
  
  return x_curly;
}

// [[Rcpp::export]]
double bicor(NumericVector x, NumericVector y){
  if (x.length() != y.length())
    stop("Two input vectors of bicor function have unequal length");
  if (any(is_na(x)) | any(is_na(y)) | any(is_infinite(x)) | any(is_infinite(y)))
    stop("NA/NaN/Inf/-Inf value in input to bicor function");

  return sum(prepare_col_bicor(x) * prepare_col_bicor(y));
}

// [[Rcpp::export]]
double pearson_coefficient(NumericVector X, NumericVector Y){
  
  double n = X.length();
  double sum_X = 0, sum_Y = 0, sum_XY = 0;
  double squareSum_X = 0, squareSum_Y = 0;
  
  for (int i = 0; i < n; i++){
    sum_X += X[i];
    sum_Y += Y[i];
    sum_XY += X[i] * Y[i];
    squareSum_X += X[i] * X[i];
    squareSum_Y += Y[i] * Y[i];
  }
  
  double cor = (n * sum_XY - sum_X * sum_Y)
              / sqrt((n * squareSum_X - sum_X * sum_X)
                       * (n * squareSum_Y - sum_Y * sum_Y));
                       
  return(cor);
}

// [[Rcpp::export]]
List cor_edge_mRNA(NumericMatrix x, double threshold){
  std::vector<int> in_v;
  std::vector<int> out_v;
  std::vector<double> cor;
  
  NumericMatrix x2 (x.nrow(), x.ncol());
  for (int i = 0; i < x.nrow(); i++){
    x2(i, _) = prepare_col_bicor(x(i, _));
  }
  
  for(int i = 0; i < x.nrow(); i++){
    for(int j = i + 1; j < x.nrow(); j++){
      //double c = bicor(x(i, _), x(j, _));
      double c = sum(x2(i, _) * x2(j, _));
      if (c >= threshold){
        //Rprintf("Correlation [%i,%i]: %f\n", i + 1, j + 1, c);
        in_v.push_back(i+1);
        out_v.push_back(j+1);
        cor.push_back(c);
      }
    }
    if (i % 100 == 0){
      checkUserInterrupt();
      Rprintf("%i/%i\n", i, x.nrow());
    }
  }
  
  List edges;
  edges["in_v"] = wrap(in_v);
  edges["out_v"] = wrap(out_v);
  edges["correlation"] = wrap(cor);
  
  return edges;
}

// [[Rcpp::export]]
List cor_edge_mRNA_miRNA(NumericMatrix x, NumericMatrix y, double threshold){
  std::vector<int> in_v;
  std::vector<int> out_v;
  std::vector<double> cor;
  
  NumericMatrix x2 (x.nrow(), x.ncol());
  for (int i = 0; i < x.nrow(); i++){
    x2(i, _) = prepare_col_bicor(x(i, _));
  }
  
  NumericMatrix y2 (y.nrow(), y.ncol());
  for (int i = 0; i < y.nrow(); i++){
    y2(i, _) = prepare_col_bicor(y(i, _));
  }
  
  for(int i = 0; i < x.nrow(); i++){
    for(int j = 0; j < y.nrow(); j++){
      //double c = bicor(x(i, _), y(j, _));
      double c = sum(x2(i, _) * y2(j, _));
      if (c <= threshold){
        //Rprintf("Correlation [%i,%i]: %f\n", i + 1, j + 1, c);
        in_v.push_back(i+1);
        out_v.push_back(j+1);
        cor.push_back(c);
      }
    }
    if (i % 100 == 0){
      checkUserInterrupt();
      Rprintf("%i/%i\n", i, x.nrow());
    }
  }
  
  List edges;
  edges["in_v"] = wrap(in_v);
  edges["out_v"] = wrap(out_v);
  edges["correlation"] = wrap(cor);
  
  return edges;
}

// R test
/*** R
#cor_edge_mRNA(as.matrix(test[1:100,]), 0.8)
*/

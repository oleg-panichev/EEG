function xSign=getSign(X,Y)  
  medPos=median(X(Y==1));
  medNeg=median(X(Y==0));
  xSign=sign(medPos-medNeg);
end
proc format;
    value treatf
        1 = "NBP组完成"
        2 = "NBP组退出"
        3 = "安慰剂组完成"
        4 = "安慰剂组退出";
run;
proc format;
value GROUP_FMT(notsorted)
1='试验组'
2='对照组'
;
value  fmt_ynn(notsorted)
1='是'
0='否'
;
value  fmt_ycx(notsorted)
1='80%-120%'
0='<80%或>120%'
;
value $ fmt_ynz (notsorted)
'是'="Y"
'否'="N"
  ;
value $fmt_fz (notsorted)
'A'='2'
'B'='1'
  ;
  value  $fmt_ynn(notsorted)
'1'='是'
'0'='否'
;
value  fmt_fc(notsorted)
1='轻度'
2='中度'
;
value $vadashsc (notsorted)
'1'='10'
'2'='5'
'3'='5'
'4'='10'
'5'='5'
'6'='5'
'7'='8'
'8'='12'
'9'='5'
'10'='5'
'11'='5'
'12'='5'
'13'='5'
'14'='5'
;
value $adcs (notsorted)
'1'='3'
'2'='3'
'3'='3'
'4'='3'
'5'='3'
'6'='7'
'7'='5'
'8'='3'
'9'='3'
'10'='3'
'11'='3'
'12'='3'
'13'='4'
'14'='3'
'15'='4'
'16'='4'
'17'='3'
'18'='3'
'19'='3'
'20'='2'
'21'='3'
'22'='4'
'23'='5'
;
value $ach (notsorted)
'乙酰胆碱（ACH）'='1'
'血管内皮生长因子（VEGF）'='2'
'脑源性神经营养因子（BDNF）'='3'
;
value $apoe (notsorted)
'E2/E2'='1'
'E2/E3'='2'
'E2/E4'='3'
'E3/E3'='4'
'E3/E4'='5'
'E4/E4'='6'
'ε3/ε3'='4'
'ε3/ε4'='5'
;
value apoe (notsorted)
1='E2/E2'
2='E2/E3'
3='E2/E4'
4='E3/E3'
5='E3/E4'
6='E4/E4'
;
value $apon (notsorted)
'LL、QQ'='1'
'LL、QR'='2'
'LL、RR'='3'
'LM、QQ'='4'
'LM、QR'='5'
;
value apon (notsorted)
1='LL、QQ'
2='LL、QR'
3='LL、RR'
4='LM、QQ'
5='LM、QR'
;
run;

proc format;
value  fmt_yn(notsorted)
1='是'
2='否'
;
value  fmt_yw(notsorted)
1='有'
2='无'
;
value  fmt_yww(notsorted)
1='有'
0='无'
;
run;
 
proc format;
    value AGE_FAZ3F
        1 = "年龄≥70"
        2 = "Fazekas 3级"
        3 = "年龄≥70且Fazekas 3级"
        4 = "年龄<70且Fazekas非3级";
run;
 
proc format;
value $fxj (notsorted)
'Y'='纳入'
'N'='剔除'
;
run;
 
 

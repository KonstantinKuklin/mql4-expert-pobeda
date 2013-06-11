/*
   Generated by EX4-TO-MQ4 decompiler V4.0.224.1 []
   Website: http://purebeam.biz
   E-mail : purebeam@gmail.com
*/
#property copyright "Copyright ?2011"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Black

#include <stdlib.mqh>

extern double StartingBalance = 10000.0;
extern string info = "CurrentBalance of -1 = Actual Account Balance";
extern double CurrentBalance = -1.0;
extern bool IncludeOpenEquity = TRUE;
extern int TicksOfSL = 200;
extern double RiskOnCapital = 0.03;
extern double RiskOnProfit = 0.25;
extern double MinLotSize = 0.01;
extern double TooMuchProfitPct = 5.0;
extern double TooMuchLossPct = 0.2;
extern bool PrintToExpertsTab = FALSE;
extern bool Show$perTick = FALSE;
extern bool ShowRiskInDollars = FALSE;
extern int FontSizeLine1 = 16;
extern int FontSizeLine2 = 12;
extern color TextColor = Red;
extern int X = 10;
extern int Y = 20;
string g_name_180 = "MasterMoneyBot";
string g_name_188 = "MasterMoneyBot2";
double gd_196 = 0.0;
bool gi_204 = TRUE;
bool gi_208 = FALSE;
int g_error_212 = 0/* NO_ERROR */;
string gs_216;
string gs_224;
string gs_unused_232 = "";
double g_minlot_240 = 0.0;
int gi_248 = 0;
string gs_252 = "";
int gi_260 = 1303171140;
bool gi_264 = FALSE;
bool gi_268 = TRUE;
bool gi_unused_272 = TRUE;

int init() {
   IndicatorShortName("MMB");
   Comment("");
   gi_204 = TRUE;
   gi_208 = FALSE;
   if (!gi_204) {
      gi_204 = FALSE;
      if (!ObjectCreate(g_name_180, OBJ_LABEL, 0, 0, 0, 0, 0)) {
         Print("Error creating label");
         gi_208 = TRUE;
      }
      if (!ObjectSet(g_name_180, OBJPROP_XDISTANCE, X)) {
         Print("Error setting XDistance of label");
         gi_208 = TRUE;
      }
      if (!ObjectSet(g_name_180, OBJPROP_YDISTANCE, Y)) {
         Print("Error setting YDistance of label");
         gi_208 = TRUE;
      }
      CheckError(71);
      if (!ObjectCreate(g_name_188, OBJ_LABEL, 0, 0, 0, 0, 0)) {
         Print("Error creating label");
         gi_208 = TRUE;
      }
      if (!ObjectSet(g_name_188, OBJPROP_XDISTANCE, X)) {
         Print("Error setting XDistance of label");
         gi_208 = TRUE;
      }
      if (!ObjectSet(g_name_188, OBJPROP_YDISTANCE, Y + FontSizeLine1 + 5)) {
         Print("Error setting YDistance of label");
         gi_208 = TRUE;
      }
      CheckError(75);
   }
   gs_224 = StringSubstr(Symbol(), 0, 3);
   gs_216 = StringSubstr(Symbol(), 3, 3);
   int l_str_len_0 = StringLen(Symbol());
   if (l_str_len_0 > 6) gs_252 = StringSubstr(Symbol(), 6, l_str_len_0 - 6);
   g_minlot_240 = MarketInfo(Symbol(), MODE_MINLOT);
   if (MinLotSize < g_minlot_240) MinLotSize = g_minlot_240;
   string ls_4 = MinimalString(MinLotSize, 10);
   if (StringLen(ls_4) == 2) gi_248 = 1;
   else gi_248 = StringLen(ls_4) - 2;
   return (0);
}

int deinit() {
   ObjectDelete(g_name_180);
   ObjectDelete(g_name_188);
   return (0);
}

int start() {
   string ls_0;
   double ld_8;
   double ld_16;
   double ld_24;
   double l_iclose_32;
   double ld_40;
   double ld_48;
   string l_str_concat_56;
   string l_str_concat_64;
   string l_str_concat_72;
 /*  if (gi_208 == FALSE) {
      if (gi_268) {
         if (gi_268 && AccountNumber() != 0) {
            gi_268 = TRUE;
            gi_unused_272 = TRUE;
            if (AccountNumber() == 9172) gi_268 = TRUE;
            else {
               if (AccountNumber() == 212919) gi_268 = TRUE;
               else {
                  if (AccountNumber() == 20253) gi_268 = TRUE;
                  else {
                     if (AccountNumber() == 39200) gi_268 = TRUE;
                     else {
                        if (AccountNumber() == 27596) gi_268 = TRUE;
                        else {
                           if (AccountNumber() == 1608940) gi_268 = TRUE;
                           else {
                              if (AccountNumber() == 2088998809) gi_268 = TRUE;
                              else {
                                 if (AccountNumber() == 66952302) gi_268 = TRUE;
                                 else {
                                    if (AccountNumber() == 10390712) gi_268 = TRUE;
                                    else {
                                       if (AccountNumber() == 10382103) gi_268 = TRUE;
                                       else {
                                          if (AccountNumber() == 168691) gi_268 = TRUE;
                                          else {
                                             if (AccountNumber() == 5434) gi_268 = TRUE;
                                             else {
                                                if (AccountNumber() == 500497548) gi_268 = TRUE;
                                                else {
                                                   if (AccountNumber() == 10336610) gi_268 = TRUE;
                                                   else {
                                                      if (AccountNumber() == 584983) gi_268 = TRUE;
                                                      else {
                                                         if (AccountNumber() == 70516) gi_268 = TRUE;
                                                         else {
                                                            if (AccountNumber() == 21152) gi_268 = TRUE;
                                                            else {
                                                               if (AccountNumber() == 7012777) gi_268 = TRUE;
                                                               else {
                                                                  if (AccountNumber() == 1001305) gi_268 = TRUE;
                                                                  else {
                                                                     if (AccountNumber() == 1145837) gi_268 = TRUE;
                                                                     else {
                                                                        if (AccountNumber() == 507157) gi_268 = TRUE;
                                                                        else {
                                                                           if (AccountNumber() == 6137701) gi_268 = TRUE;
                                                                           else {
                                                                              if (AccountNumber() == 59578) gi_268 = TRUE;
                                                                              else {
                                                                                 if (AccountNumber() == 32095) gi_268 = TRUE;
                                                                                 else {
                                                                                    if (AccountNumber() == 75689) gi_268 = TRUE;
                                                                                    else {
                                                                                       if (AccountNumber() == 119318) gi_268 = TRUE;
                                                                                       else {
                                                                                          if (AccountNumber() == 59578) gi_268 = TRUE;
                                                                                          else {
                                                                                             if (AccountNumber() == 561195) gi_268 = TRUE;
                                                                                             else {
                                                                                                if (AccountNumber() == 6098839) gi_268 = TRUE;
                                                                                                else {
                                                                                                   if (AccountNumber() == 6098839) gi_268 = TRUE;
                                                                                                   else {
                                                                                                      if (AccountNumber() == 506440) gi_268 = TRUE;
                                                                                                      else {
                                                                                                         if (AccountNumber() == 4696) gi_268 = TRUE;
                                                                                                         else {
                                                                                                            if (AccountNumber() == 19047732) gi_268 = TRUE;
                                                                                                            else {
                                                                                                               if (AccountNumber() == 1223950) gi_268 = TRUE;
                                                                                                               else {
                                                                                                                  if (AccountNumber() == 27269) gi_268 = TRUE;
                                                                                                                  else {
                                                                                                                     if (AccountNumber() == 863203) gi_268 = TRUE;
                                                                                                                     else
                                                                                                                        if (AccountNumber() == 98797) gi_268 = TRUE;
                                                                                                                  }
                                                                                                               }
                                                                                                            }
                                                                                                         }
                                                                                                      }
                                                                                                   }
                                                                                                }
                                                                                             }
                                                                                          }
                                                                                       }
                                                                                    }
                                                                                 }
                                                                              }
                                                                           }
                                                                        }
                                                                     }
                                                                  }
                                                               }
                                                            }
                                                         }
                                                      }
                                                   }
                                                }
                                             }
                                          }
                                       }
                                    }
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            } */
      /*   //   ls_0 = "Email MasterMoneyBot@gmail.com for license \'" + AccountNumber() + "\'";
            if (!gi_268) {
               Comment(ls_0);
               Alert(ls_0);
            } else { 
               if (!gi_264) {
                  if (TimeLocal() > gi_260) gi_268 = FALSE;
                   if (!gi_268) {
                     Comment(ls_0);
                     Alert(ls_0);
                  }
               }
            }
         }
         if (!gi_268) deinit(); */
         //else {
            if (IncludeOpenEquity) ld_8 = AccountEquity();
            else ld_8 = AccountBalance();
            if (CurrentBalance == -1.0) gd_196 = ld_8 - StartingBalance;
            else gd_196 = CurrentBalance - StartingBalance;
            if (gd_196 / StartingBalance > TooMuchProfitPct) Comment(StringConcatenate("Profit has exceeded ", DoubleToStr(100.0 * TooMuchProfitPct, 0), "%...recommend you change StartingBalance or CurrentBalance"));
            if ((-gd_196) / StartingBalance > TooMuchLossPct) Comment(StringConcatenate("Loss has exceeded ", DoubleToStr(100.0 * TooMuchLossPct, 0), "%...recommend you change StartingBalance or CurrentBalance"));
            ld_16 = 100000.0 * MinLotSize * Point;
            ld_24 = ld_16;
            if (gs_216 != "USD") {
               l_iclose_32 = iClose("USD" + gs_216 + gs_252, PERIOD_H1, 0);
               if (l_iclose_32 > 0.0) {
                  ld_24 = 1 / l_iclose_32;
                  CheckError(153);
               } else ld_24 = iClose(gs_216 + "USD" + gs_252, PERIOD_H1, 0);
               ld_24 *= ld_16;
            }
            ld_40 = StartingBalance * RiskOnCapital + gd_196 * RiskOnProfit;
            ld_48 = ld_40 / TicksOfSL / ld_24 * MinLotSize;
            if (ld_48 < 0.0) {
               Comment("Loss has exceeded normal levels...Recommended lot size cannot be calculated");
               gi_208 = TRUE;
               deinit();
            } else {
               if (ld_48 < MinLotSize) ld_48 = MinLotSize;
               if (Show$perTick) l_str_concat_56 = StringConcatenate("  $/tick=", DoubleToStr(ld_24, 3));
               else l_str_concat_56 = "";
               if (ShowRiskInDollars) l_str_concat_64 = StringConcatenate("$", DoubleToStr(MathAbs(ld_40), 2), " at risk");
               else l_str_concat_64 = "";
               l_str_concat_72 = StringConcatenate("Next position size: ", DoubleToStr(ld_48, gi_248), " lots (with ", TicksOfSL, "-ticks SL)", l_str_concat_56);
               if (PrintToExpertsTab) Print(StringConcatenate(l_str_concat_72, " ", l_str_concat_64));
               if (!ObjectSetText(g_name_180, l_str_concat_72, FontSizeLine1, "Arial", TextColor)) {
                  gi_208 = TRUE;
                  CheckError(190);
                  if (g_error_212 == 4202/* OBJECT_DOES_NOT_EXIST */) {
                     if (!ObjectCreate(g_name_180, OBJ_LABEL, 0, 0, 0, 0, 0)) {
                        Print("Error creating label");
                        gi_208 = TRUE;
                     }
                     if (!ObjectSet(g_name_180, OBJPROP_XDISTANCE, X)) {
                        Print("Error setting XDistance of label");
                        gi_208 = TRUE;
                     }
                     if (!ObjectSet(g_name_180, OBJPROP_YDISTANCE, Y)) {
                        Print("Error setting YDistance of label");
                        gi_208 = TRUE;
                     }
                     gi_208 = FALSE;
                  } else Print("Output label created");
               }
               if (!ObjectSetText(g_name_188, l_str_concat_64, FontSizeLine2, "Arial", TextColor)) {
                  gi_208 = TRUE;
                  CheckError(201);
                  if (g_error_212 == 4202/* OBJECT_DOES_NOT_EXIST */) {
                     if (!ObjectCreate(g_name_188, OBJ_LABEL, 0, 0, 0, 0, 0)) {
                        Print("Error creating label2");
                        gi_208 = TRUE;
                     }
                     if (!ObjectSet(g_name_188, OBJPROP_XDISTANCE, X)) {
                        Print("Error setting XDistance of label2");
                        gi_208 = TRUE;
                     }
                     if (!ObjectSet(g_name_188, OBJPROP_YDISTANCE, Y + FontSizeLine1 + 5)) {
                        Print("Error setting YDistance of label2");
                        gi_208 = TRUE;
                     }
                     gi_208 = FALSE;
                  } else Print("Output label2 created");
               }
            }
         }
      //}
   //}
   return (0);
//}

void CheckError(int ai_unused_0) {
   string ls_4;
   g_error_212 = GetLastError();
   if (g_error_212 > 1/* NO_RESULT */) {
      ls_4 = "";
      if (ls_4 == "") ls_4 = ErrorDescription(g_error_212) + " (#" + g_error_212 + ")";
   }
}

string MinimalString(double ad_0, int ai_8) {
   string l_dbl2str_12 = DoubleToStr(ad_0, ai_8);
   for (int li_20 = StringLen(l_dbl2str_12) - 1; StringGetChar(l_dbl2str_12, li_20) == '0' || StringGetChar(l_dbl2str_12, li_20) == ' '; li_20--) l_dbl2str_12 = StringSetChar(l_dbl2str_12, li_20, ' ');
   return (StringTrimRight(l_dbl2str_12));
}
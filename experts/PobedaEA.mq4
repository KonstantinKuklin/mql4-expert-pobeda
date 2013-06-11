//
// Советнмк по стратегии "Победа версия 1" с форума tradelikeapro.ru от Skylover410
//
#property copyright "EURUSD-M1 (c) dev by stelz, intelvps.ru"
#property link      "http://www.intelvps.ru"


extern bool UseMM = false;
extern double FixLot = 0.1;

extern double SL = 50;
extern double TP = 50;
extern bool UseCenterTmaForTP=true;
extern bool UseCenterTmaForSL=true;
extern double UseCenterTmaForSLRatio=1.5;
extern bool UseCenterTmaForTPAdaptive=true;

extern bool UseCenterTmaForTrade=false;
extern int extCenterLine = 3;

extern double kanalMin=100;
extern double spreadMax = 21;
extern double extSSRC = 0.75;
extern int EA_magic = 9494;
extern double extKanal=0;

extern bool UseTrend=true;
extern string Comment_UseTrendMethod = "1 - MA, 2 - UltraSignal, 3 - TMA Slope";
extern int UseTrendMethod=3;

   
extern string Comment_slippage = "разрешенное проскальзывание цены в пипсах";
extern double slippage = 5.0;

extern int gmtshift=3;                   // gmt offset
extern int StartHour = 7;
extern int StartMinute = 0;
extern int EndHour = 21;
extern int EndMinute = 0;

extern string Comment_NewsFilter = "Фильтр торговли во время новостей";
extern bool UseNewsFilter = false;
extern int MinsBeforeNews = 10; // mins before an event to stay out of trading
extern int MinsAfterNews  = 20; // mins after  an event to stay out of trading
extern bool 	IncludeHigh 		= true;
extern bool 	IncludeMedium 		= true;
extern bool 	IncludeLow 			= false;
extern bool 	IncludeSpeaks 		= true; 		// news items with "Speaks" in them have different characteristics
bool NewsTime = false;
int minutesUntilNextEvent = 0;
int minutesSincePrevEvent = 0;


//trail
//--------------------------------------------------------------------
extern int     TrailingStop         = 0;     //длинна тралла, если 0 то нет тралла
extern int     StepTrall            = 0;      //шаг тралла - перемещать стоплосс не ближе чем StepTrall
extern int     NoLoss               = 0,     //перевод в безубыток при заданном кол-ве пунктов прибыли, если 0 то нет перевода в безубыток
               MinProfitNoLoss      = 0;      //минимальная прибыль при переводе вбезубыток
//--------------------------------------------------------------------
int  STOPLEVEL,TimeBar;
///

   
///////MM
//#property indicator_chart_window
//#property indicator_buffers 1
//#property indicator_color1 Black

#include <stdlib.mqh>

extern double StartingBalance = 300.0;
extern string info = "CurrentBalance of -1 = Actual Account Balance";
extern double CurrentBalance = -1.0;
extern bool IncludeOpenEquity = TRUE;

int TicksOfSL = 50;

extern double RiskOnCapital = 0.05;
extern double RiskOnProfit = 0.25;
extern double MinLotSize = 0.01;
extern double TooMuchProfitPct = 5.0;
extern double TooMuchLossPct = 0.2;
bool PrintToExpertsTab = FALSE;
bool Show$perTick = FALSE;
bool ShowRiskInDollars = FALSE;
int FontSizeLine1 = 16;
int FontSizeLine2 = 12;
color TextColor = Red;
int X = 10;
int Y = 20;
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
//////


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
  TicksOfSL=SL;
  /////MM
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
   //// end MM
   
   
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
  
  ///mm
  ObjectDelete(g_name_180);
   ObjectDelete(g_name_188);
  //mm
  
  
  
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  if(UseNewsFilter)
      NewsHandling();
      
  TicksOfSL=SL;
  ////////MM
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
   
   double nextLotSize;
 
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
///
               if (UseMM==true)
                  nextLotSize = ld_48;
               else
                  nextLotSize = FixLot;
////
               l_str_concat_72 = StringConcatenate("Next position size: ", DoubleToStr(ld_48, gi_248), " lots (with ", TicksOfSL, "-ticks SL)", l_str_concat_56);
   
               /*
               if (PrintToExpertsTab) Print(StringConcatenate(l_str_concat_72, " ", l_str_concat_64));
               if (!ObjectSetText(g_name_180, l_str_concat_72, FontSizeLine1, "Arial", TextColor)) {
                  gi_208 = TRUE;
                  CheckError(190);
                  if (g_error_212 == 4202) {
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
                  if (g_error_212 == 4202) {
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
               } */
            }
         //}
////////////MM         
  
  
  
   double valSSRC=iCustom(NULL, 0, "SSRC", 3, 21, 2, 6, 0,0);
   double valSSRCpre=iCustom(NULL, 0, "SSRC", 3, 21, 2, 6, 0,1);
   
   double valExtremeTMALineCenter=iCustom(NULL, 0, "ExtremeTMALine", "Current", 56, 0, 2.8, 100, 0.5, 0,0);
   double valExtremeTMALineUp=iCustom(NULL, 0, "ExtremeTMALine", "Current", 56, 0, 2.8, 100, 0.5, 1,0);   
   double valExtremeTMALineDown=iCustom(NULL, 0, "ExtremeTMALine", "Current", 56, 0, 2.8, 100, 0.5, 2,0);   

   bool TrendBuy=true;
   bool TrendSell=true;

   string TrendInfo="";   
   if(UseTrend) {

if(UseTrendMethod==1) {
   double valEMA_fast=iMA(NULL,0,170,0,MODE_SMA,PRICE_CLOSE,0);
   double valEMA_slow=iMA(NULL,0,1000,0,MODE_SMA,PRICE_CLOSE,0);
   double valClose=iClose(NULL, 0, 1);
   TrendInfo="MovingAverage";
   
   if(valEMA_fast>valEMA_slow && valClose > valEMA_fast) {
      TrendBuy=true;
      TrendSell=false;
      }
   if(valEMA_fast<valEMA_slow && valClose < valEMA_fast) {
      TrendBuy=false;
      TrendSell=true;
      }
      
}

if(UseTrendMethod==2) {
   double valUltraSignalSell=iCustom(NULL, 0, "Ultra-Signal", 0, 0);
   double valUltraSignalBuy=iCustom(NULL, 0, "Ultra-Signal", 1, 0);
   if(valUltraSignalSell<valUltraSignalBuy) {
      TrendBuy=false;
      TrendSell=true;
      TrendInfo="UltraSignall SELL";
      }
   else {
      TrendBuy=true;
      TrendSell=false;
      TrendInfo="UltraSignall BUY";
      }
}
      
if(UseTrendMethod==3) {
double valTmaSlope=iCustom(NULL, 0, "TmaSlope.v1.5 Normalized", 6, 0);
//Print("SLOPE:"+valTmaSlope);
TrendInfo="SLOPE:"+DoubleToStr(valTmaSlope, 2);
if(valTmaSlope>=0.25) {
   TrendBuy=true;
   TrendSell=false;
   }
if(valTmaSlope<=-0.25) {
   TrendBuy=false;
   TrendSell=true;
   }


}
      
      /*
   if(valEMA_fast < valClose < valEMA_slow  )  {
      TrendBuy=false;
      TrendSell=false;
      }

   if(valEMA_fast > valClose > valEMA_slow  )  {
      TrendBuy=false;
      TrendSell=false;
      }
      */
   }
   
      

   //double val=iCustom(NULL, 0, "CurrencyPowerMeter", "", "", "", 2, 8, "", 30, 1, "EUR,USD", "EURUSD", 0,0);

   
   //Print("v: "+val);
   //Print("SSRC: "+valSSRC);
   //Print("TMAcenter: "+valExtremeTMALineCenter);
   //Print("TMAup: "+valExtremeTMALineUp);
   //Print("TMAdown: "+valExtremeTMALineDown);
   
   
   double Spread = MathAbs(Bid-Ask);
   double kanal = MathAbs(valExtremeTMALineUp-valExtremeTMALineDown);
   
   //Print("SPREAD:"+Spread + spreadMax*Point);
   
   
   int ticket;
   int totalOrders=0;

for( int i = 0 ; i < OrdersTotal() ; i++ ){
         if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ){
         totalOrders++;
        break;
        }
        
         if( OrderMagicNumber() != EA_magic ){
            continue;
           }
        if( OrderSymbol() != Symbol() ){
            continue;
            }
   totalOrders++;
   }


      
   bool allowOrders = false;
   bool tmaSell = false;
   bool tmaBuy = false;
   bool ssrcSell = false;
   bool ssrcBuy = false;
   bool allowSpread=false;
   bool allowKanal=false;
   bool tradeTime=TradeTime();
   //bool allowExtKanal=false;
   if(totalOrders==0)
         allowOrders = true;
   if(valExtremeTMALineDown - (kanal*extKanal)  >Ask)
         tmaBuy = true;
   if(valExtremeTMALineUp + (kanal*extKanal) <Bid)
         tmaSell=true;
         
   if(UseCenterTmaForTrade==true) {
      if(MathAbs(valExtremeTMALineCenter-Ask)<extCenterLine*Point) {
         tmaSell=true;
         tmaBuy=true;
            valUltraSignalSell=iCustom(NULL, 0, "Ultra-Signal", 0, 0);
            valUltraSignalBuy=iCustom(NULL, 0, "Ultra-Signal", 1, 0);
            if(valUltraSignalSell<valUltraSignalBuy) {
               TrendBuy=false;
               TrendSell=true;
               TrendInfo="UltraSignall SELL";
               }
            else {
               TrendBuy=true;
               TrendSell=false;
               TrendInfo="UltraSignall BUY";
               }
      
      }
   }
         
   if(valSSRC < -extSSRC)
         ssrcBuy = true;
   if(valSSRC > extSSRC)
         ssrcSell=true;
   if(Spread < spreadMax*Point)
         allowSpread=true;
   if(kanal>kanalMin*Point)
         allowKanal=true;
   

  for( i = 0 ; i < OrdersTotal() ; i++ ){
         if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ){
        break;
        }
        
         if( OrderMagicNumber() != EA_magic ){
            continue;
           }
        if( OrderSymbol() != Symbol() ){
            continue;
            }
         
     double priceTP=0, priceSL=0;
        
     static int PrevMinute1 = -1;
     double sumOrderProfit= OrderProfit()+OrderSwap()+OrderCommission();
    /*
     if (Minute() != PrevMinute1 && UseCenterTmaForTP==true)
     {
         PrevMinute1 = Minute();
         priceTP = valExtremeTMALineCenter;
         if( OrderType() == OP_BUY ){
               OrderModify(OrderTicket(),OrderOpenPrice(), OrderStopLoss(),priceTP,0,Green);
            }
         else if( OrderType() == OP_SELL ){
               OrderModify(OrderTicket(),OrderOpenPrice(), OrderStopLoss(),priceTP,0,Red);
            }   
     }   
    */   
    
    if(UseCenterTmaForTPAdaptive==true  &&  UseCenterTmaForTrade==false && MathAbs(valExtremeTMALineCenter-Ask)<(extCenterLine*Point))
    {
      if( OrderType() == OP_BUY ){
         if(sumOrderProfit > 0) {OrderClose(OrderTicket(), OrderLots(), Bid, slippage, Blue);
                return (0);}
      }
      
      if( OrderType() == OP_SELL ){
         if(sumOrderProfit > 0) {OrderClose(OrderTicket(), OrderLots(), Ask, slippage, Red);
                return (0);}
      }
    
    }

    
    
//|| ( UseCenterTmaForTPAdaptive==true && Minute() != PrevMinute1 && UseCenterTmaForTP==true && TrailingStop==0)        
         if (OrderStopLoss()==0 || OrderTakeProfit()==0 ) {
            PrevMinute1 = Minute();
            double VMin=MarketInfo(Symbol(),MODE_POINT)* (MarketInfo(Symbol(),MODE_STOPLEVEL)+slippage); 
            double VStopLossLong=Bid- VMin ;
            double VTakeProfitLong=Ask+ VMin ;
            double VStopLossShort=Ask+ VMin ;
            double VTakeProfitShort=Bid-VMin ;
            
            
            if( OrderType() == OP_BUY ){
                if(UseCenterTmaForTP==true) 
                   priceTP = valExtremeTMALineCenter;
                else
                   priceTP=OrderOpenPrice()+TP*Point;
               
               if(UseCenterTmaForSL==true)
                  priceSL= OrderOpenPrice()-(kanal/2*UseCenterTmaForSLRatio);
               else 
                  priceSL= OrderOpenPrice()-SL*Point;
               
               if(priceTP<VTakeProfitLong) {    
                     priceTP = VTakeProfitLong;
                     if(sumOrderProfit>0) {
                        OrderClose(OrderTicket(), OrderLots(), Bid, slippage, Blue);
                        return (0);
                        }
                     }
               if(priceSL>VStopLossLong)   { 
                     priceSL = VStopLossLong;
                     
                     }
                   
               OrderModify(OrderTicket(),OrderOpenPrice(),priceSL,priceTP,0,Blue);
            }
            else if( OrderType() == OP_SELL ){
                     if(UseCenterTmaForTP==true) {
                         priceTP = valExtremeTMALineCenter;
                         }
                      else
                         priceTP=OrderOpenPrice()-TP*Point;
                         
                if(UseCenterTmaForSL==true)
                  priceSL=OrderOpenPrice()+(kanal/2*UseCenterTmaForSLRatio);          
                else                           
                  priceSL=OrderOpenPrice()+SL*Point;          
               
               
               if(priceTP>VTakeProfitShort)    {
                     priceTP = VTakeProfitShort;
                     if(sumOrderProfit>0) {
                            OrderClose(OrderTicket(), OrderLots(), Ask, slippage, Red);
                            return (0);
                            }
                     }
               if(priceSL<VStopLossLong)    {
                     priceSL = VStopLossLong;
                     
                     }

               
               OrderModify(OrderTicket(),OrderOpenPrice(),priceSL,priceTP,0,Red);
            }   
         }
        } 






   TrailingStop();



      

   //Print("Ord:"+allowOrders+" tS:"+tmaSell+" tB"+tmaBuy+" sS:"+ssrcSell+" sB:"+ssrcBuy+ " sp:"+allowSpread+" k:"+allowKanal+ " time:"+tradeTime);         
   
   if(totalOrders==0 && tradeTime && tmaBuy &&  valSSRC < -extSSRC && Spread < spreadMax*Point && kanal>kanalMin*Point && NewsTime==0 && TrendBuy==true)
   //if(totalOrders==0 && valSSRC > -extSSRC && valSSRCpre <-extSSRC && Spread < spreadMax*Point && kanal>kanalMin*Point )
    {
     //ticket=OrderSend(Symbol(),OP_BUY, nextLotSize ,Ask,5,Bid-SL*Point,Ask+TP*Point,"My order #",16384,0,Green);
     ticket=OrderSend(Symbol(),OP_BUY, nextLotSize ,Ask,slippage,0,0,"My order #", EA_magic,0,Blue);
     if(ticket<0)
       {
        Print("OrderSend failed with error #",GetLastError());
        return(0);
       }
    }
   
   
   if(totalOrders==0 && tradeTime && tmaSell &&  valSSRC > extSSRC && Spread < spreadMax*Point && kanal>kanalMin*Point && NewsTime==0 && TrendSell==true)
    //if(totalOrders==0 && valSSRC < extSSRC  && valSSRCpre > extSSRC && Spread < spreadMax*Point && kanal>kanalMin*Point)
    {
     ticket=OrderSend(Symbol(),OP_SELL, nextLotSize ,Bid,slippage,0,0,"My order #", EA_magic,0,Red);
     if(ticket<0)
       {
        Print("OrderSend failed with error #",GetLastError());
        return(0);
       }
    }
   
//----
   
//----




      Comment(" \nPobeda v1.09", 
         "\nСерверное время" + TimeToStr(TimeCurrent(), TIME_SECONDS) + " (GMT: "+TimeToStr(TimeCurrent()-gmtshift*3600, TIME_SECONDS)+")", 
         "\nТорговое время: " +YesNo(tradeTime),
         "\nНет открытых ордеров: "+YesNo(allowOrders),
         "\nСпред: "+DoubleToStr(Spread/Point, 1)+" (Max: "+ DoubleToStr(spreadMax,1) +") "+ YesNo(allowSpread),
         "\nШирина канала: "+DoubleToStr(kanal/Point,1) + "(Min: "+DoubleToStr(kanalMin,1) + ") " +YesNo(allowKanal),
         "\nTMA Sell: "+YesNo(tmaSell),
         "\nTMA Buy: "+YesNo(tmaBuy),
         "\nSSRC Sell: "+YesNo(ssrcSell),
         "\nSSRC Buy: "+YesNo(ssrcBuy),
         "\nСледующий лот: "+DoubleToStr(nextLotSize,2),
         "\nФильтр по новостям: "+YesNo(UseNewsFilter),
         "\nВремя новостей: "+YesNo(NewsTime),
         "\nПредыдущая новость была "+minutesSincePrevEvent+" мин. назад",
         "\nДо следующей новости осталось "+minutesUntilNextEvent+" мин.",
         "\nTrendBuy: "+YesNo(TrendBuy)+" TrendSell: "+YesNo(TrendSell)+ " Method: "+TrendInfo,
         
      "\n");
   
   
   


   return(0);
  }
//+------------------------------------------------------------------+



////MM
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
///MM



bool TradeTime() {
   int now = 60 * TimeHour(TimeCurrent()) + TimeMinute(TimeCurrent());
   int start = 60 * (StartHour+gmtshift) + StartMinute;
   int end = 60 * (EndHour+gmtshift) + EndMinute;
   if (start == end) return (0);
   if (start < end) {
      if (!(!(now >= start && now < end))) return (1);
      return (0);
   }
   if (start > end) {
      if (!(!(now >= start || now < end))) return (1);
      return (0);
   }
   return (0);
}

string YesNo (int value) 
{
if(value>0)
   return ("Да");
else
   return ("Нет");
}

void NewsHandling()
 {
     static int PrevMinute = -1;

     if (Minute() != PrevMinute)
     {
         PrevMinute = Minute();
    
         minutesSincePrevEvent =
             iCustom(NULL, 0, "FFCal-fix_by_stelz", IncludeHigh, IncludeMedium, IncludeLow, IncludeSpeaks, true, gmtshift, 1, 0);
 
         minutesUntilNextEvent =
             iCustom(NULL, 0, "FFCal-fix_by_stelz", IncludeHigh, IncludeMedium, IncludeLow, IncludeSpeaks, true, gmtshift, 1, 1);
 
         NewsTime = false;
         if ((minutesUntilNextEvent <= MinsBeforeNews) || 
            (minutesSincePrevEvent <= MinsAfterNews))
         {
             NewsTime = true;
         }
     }
 }//newshandling
 
 
 void TrailingStop() {
 //RefreshRates();
 STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
      double OSL,OTP,OOP,StLo,SL,TP;
      double Profit,ProfitS,ProfitB,LB,LS,NLb,NLs,price_b,price_s,OL,sl;
      int b,s,OT,OMN;
      for (int i=OrdersTotal()-1; i>=0; i--)
      {                                               
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            OMN = OrderMagicNumber();
            if (OrderSymbol() == Symbol())
            {
               OOP = NormalizeDouble(OrderOpenPrice(),Digits);
               OT = OrderType();
               OL = OrderLots();
               if (OT==OP_BUY)
               {
                  price_b = price_b+OOP*OL;
                  b++; LB+= OL;
                  ProfitB+=OrderProfit()+OrderSwap()+OrderCommission();
               }
               if (OT==OP_SELL)
               {
                  price_s = price_s+OOP*OL;
                  s++;LS+= OL;
                  ProfitS+=OrderProfit()+OrderSwap()+OrderCommission();
               }
            }
         }
      }
      if (b>0) 
      {
         NLb = NormalizeDouble(price_b/LB,Digits);
     }
      if (s>0) 
      {
         NLs = NormalizeDouble(price_s/LS,Digits);
      }
      int OTicket;
      for (i=0; i<OrdersTotal(); i++)
      {    
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if (OrderSymbol()==Symbol())
            { 
               OT = OrderType(); 
               OSL = NormalizeDouble(OrderStopLoss(),Digits);
               OTP = NormalizeDouble(OrderTakeProfit(),Digits);
               OOP = NormalizeDouble(OrderOpenPrice(),Digits);
               SL=OSL;TP=OTP;
               if (OT==OP_BUY)             
               {  
                  b++;
                  if (OSL==0 && SL>=STOPLEVEL && SL!=0)
                  {
                      SL = NormalizeDouble(Bid - SL   * Point,Digits);
                  } 
                  else SL=OSL;
                  if (OTP==0 && TP>=STOPLEVEL && TP!=0)
                  {
                      TP = NormalizeDouble(Ask + TP * Point,Digits);
                  } 
                  else TP=OTP;
                  if (NoLoss>=STOPLEVEL && OSL<NLb && NoLoss!=0)
                  {
                     if (OOP<=NLb && NLb!=0 && NLb <= NormalizeDouble(Bid-NoLoss*Point,Digits)) 
                        SL = NormalizeDouble(NLb+MinProfitNoLoss*Point,Digits);
                  }
                  if (TrailingStop>=STOPLEVEL && TrailingStop!=0)
                  {
                     StLo = NormalizeDouble(Bid - TrailingStop*Point,Digits); 
                     if (StLo>=NLb && NLb!=0) if (StLo > OSL) SL = StLo;
                  }
                  if (SL != OSL || TP != OTP)
                  {  
                     OTicket=OrderTicket();
                     if (!OrderModify(OTicket,OOP,SL,TP,0,White)) Print("Error OrderModify ",GetLastError());
                  }
               }                                         
               if (OT==OP_SELL)        
               {
                  s++;
                  if (OSL==0 && SL>=STOPLEVEL && SL!=0)
                  {
                     SL = NormalizeDouble(Ask + SL   * Point,Digits);
                  }
                  else SL=OSL;
                  if (OTP==0 && TP>=STOPLEVEL && TP!=0)
                  {
                      TP = NormalizeDouble(Bid - TP * Point,Digits);
                  }
                  else TP=OTP;
                  if (NoLoss>=STOPLEVEL && (OSL>NLs || OSL==0) && NoLoss!=0)
                  {
                     if (OOP>=NLs && NLs!=0 && NLs >= NormalizeDouble(Ask+NoLoss*Point,Digits)) 
                        SL = NormalizeDouble(NLs-MinProfitNoLoss*Point,Digits);
                  }
                  if (TrailingStop>=STOPLEVEL && TrailingStop!=0)
                  {
                     StLo = NormalizeDouble(Ask + TrailingStop*Point,Digits); 
                     if (StLo<=NLs && NLs!=0) if (StLo < OSL || OSL==0) SL = StLo;
                  }
                  if ((SL != OSL || OSL==0) || TP != OTP)
                  {  
                     OTicket=OrderTicket();
                     if (!OrderModify(OTicket,OOP,SL,TP,0,White)) Print("Error OrderModify ",GetLastError());
                  }
}
}
}
}
}             
            
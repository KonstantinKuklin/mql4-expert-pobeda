//+------------------------------------------------------------------+
//|                             CurrencyPowerMeter_fixed_Graybit.mq4 |
//|                     Copyright 2013, Kuklin Konstantin Alexeevich |
//|                                      konstantin.kuklin@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Kuklin Konstantin Alexeevich"
#property link      "konstantin.kuklin@gmail.com"

#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_separate_window

extern string note = " ======= Authentication SETTINGS ======";
extern string username = "";
extern string password = "";
extern double LowValue = 2.0;
extern double MaxValue = 8.0;
extern string PairAlert = "";
extern int AlertDelay = 30;
extern int Hours = 1;
extern string sOutput = "EUR,USD";
extern string sPairs = "EURUSD";
extern color cCurrency = Lime;
extern color cScoreHigh = Aqua;
extern color cScoreHour = Orange;
string gsa_160[16];
string gsa_164[8];
int gia_168[8] = {220, 190, 160, 130, 100, 70, 40, 10};
int gia_172[] = {16612911, 16620590, 16702510, 15990063, 11206190, 5569869, 4193654, 3669164, 3407316, 3144445, 3144189, 3138813, 3069181, 3126526, 3046654, 3098621, 4207864, 4207864, 4207864, 4207864};
int gia_176[11] = {0, 4, 11, 23, 39, 50, 61, 78, 89, 96, 100};
int gi_180 = 16;
int gi_184 = 8;
double gda_188[8];
double gda_192[16];
double gda_196[16];
double gda_200[8];
double gda_204[16];
double gda_208[16];
int g_datetime_212 = 0;
int g_str2int_216 = 0;
bool gi_220 = TRUE;
bool gi_224 = TRUE;
int gia_228[64] = {65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47};
int gi_232 = 1;
string gs_dummy_236;
int gi_244 = 0;
int gi_248 = 0;
int g_count_252 = 0;
string gs_256;
int gia_264[1];
string gs_272 = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

double     EURBuffer[];
double     USDBuffer[];
int init() {

//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   //IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,EURBuffer);
   SetIndexBuffer(1,USDBuffer);
//---- name for DataWindow and indicator subwindow label
   SetIndexLabel(0,"EUR");
   SetIndexLabel(1,"USD");
   
   int li_12;
   g_str2int_216 = 0;
   gi_220 = TRUE;
   gi_224 = TRUE;
   string ls_0 = sOutput;
   int index_8 = 0;
   while (StringLen(ls_0) > 0) {
      li_12 = StringFind(ls_0, ",");
      gsa_164[index_8] = StringSubstr(ls_0, 0, 3);
      ls_0 = StringSubstr(ls_0, li_12 + 1);
      index_8++;
      if (li_12 < 0) break;
   }
   gi_184 = index_8;
   if (gi_184 > 8) {
      gi_184 = 8;
      Comment("\n\n ERRORR:\n  Maximum NUMBER of Output Currencies is 8 \n Only first 8 will be taken");
   }
   index_8 = 0;
   ls_0 = sPairs;
   while (StringLen(ls_0) > 0) {
      li_12 = StringFind(ls_0, ",");
      gsa_160[index_8] = StringSubstr(ls_0, 0, li_12);
      ls_0 = StringSubstr(ls_0, li_12 + 1);
      index_8++;
      if (li_12 < 0) break;
   }
   gi_180 = index_8;
   if (gi_180 > 16) {
      gi_180 = 16;
      Comment("\n\n ERRORR:\n  Maximum NUMBER of Pairs is 16 \n Only first 16 will be taken");
   }
   return (0);
}

int start() {
   string text_0;
   int count_16;
   int count_20;
   string ls_24;
   double ld_32;
   double ld_40;
   double low_48;
   double ld_56;
   double ld_72;
   double bid_80;
   if (gi_224 == TRUE && g_str2int_216 == 0) {
      gi_224 = FALSE;
   }
   double ld_88 = 0.01;
   if (gi_220 == TRUE) {
      for (int index_8 = 0; index_8 < gi_180; index_8++) {
         RefreshRates();
         ld_88 = 0.0001;
         ls_24 = gsa_160[index_8];
         if (StringSubstr(ls_24, 3, 3) == "JPY") ld_88 = 0.01;
         low_48 = MarketInfo(ls_24, MODE_LOW);
         bid_80 = MarketInfo(ls_24, MODE_BID);
         ld_56 = (bid_80 - low_48) / MathMax(MarketInfo(ls_24, MODE_HIGH) - low_48, ld_88);
         gda_192[index_8] = CheckRatio(100.0 * ld_56);
         gda_196[index_8] = 9.9 - CheckRatio(100.0 * ld_56);
         low_48 = MyLowest(ls_24);
         ld_72 = MyHighest(ls_24);
         ld_56 = (bid_80 - low_48) / MathMax(ld_72 - low_48, ld_88);
         gda_208[index_8] = CheckRatio(100.0 * ld_56);
         gda_204[index_8] = 9.9 - CheckRatio(100.0 * ld_56);
      }
      for (int index_12 = 0; index_12 < gi_184; index_12++) {
         count_16 = 0;
         count_20 = 0;
         ld_32 = 0;
         ld_40 = 0;
         for (index_8 = 0; index_8 < gi_180; index_8++) {
            if (StringSubstr(gsa_160[index_8], 0, 3) == gsa_164[index_12]) {
               ld_32 += gda_192[index_8];
               count_16++;
               ld_40 += gda_208[index_8];
               count_20++;
            }
            if (StringSubstr(gsa_160[index_8], 3, 3) == gsa_164[index_12]) {
               ld_32 += gda_196[index_8];
               count_16++;
               ld_40 += gda_204[index_8];
               count_20++;
            }
            if (count_16 > 0) gda_188[index_12] = NormalizeDouble(ld_32 / count_16, 1);
            else gda_188[index_12] = -1;
            if (count_20 > 0) gda_200[index_12] = NormalizeDouble(ld_40 / count_20, 1);
            else gda_200[index_12] = -1;
         }
      }
/*
      for(int i =0; i < 3;i++){
         Print(i,"-",gda_200[i],"|",gda_188[i],"|",gia_172[i],"|",cScoreHour);
      }
*/
     EURBuffer[0] = gda_200[0];
     USDBuffer[0] = gda_200[1];
   }
   return (0);
}

int CheckRatio(double ad_0) {
   int li_ret_8 = -1;
   if (ad_0 <= 0.0) li_ret_8 = 0;
   else {
      for (int index_12 = 0; index_12 < 11; index_12++) {
         if (ad_0 < gia_176[index_12]) {
            li_ret_8 = index_12 - 1;
            break;
         }
      }
      if (li_ret_8 == -1) li_ret_8 = 9.9;
   }
   return (li_ret_8);
}

double MyLowest(string a_symbol_0) {
   double ilow_8 = iLow(a_symbol_0, 0, 0);
   int timeframe_16 = 15;
   int li_20 = 4;
   if (Hours < 3) {
      timeframe_16 = 5;
      li_20 = 12;
   }
   for (int li_24 = 0; li_24 < Hours * li_20; li_24++)
      if (ilow_8 > iLow(a_symbol_0, timeframe_16, li_24)) ilow_8 = iLow(a_symbol_0, timeframe_16, li_24);
   return (ilow_8);
}

double MyHighest(string a_symbol_0) {
   double ihigh_8 = iHigh(a_symbol_0, 0, 0);
   int timeframe_16 = 15;
   int li_20 = 4;
   if (Hours < 3) {
      timeframe_16 = 5;
      li_20 = 12;
   }
   for (int li_24 = 0; li_24 < Hours * li_20; li_24++)
      if (ihigh_8 < iHigh(a_symbol_0, timeframe_16, li_24)) ihigh_8 = iHigh(a_symbol_0, timeframe_16, li_24);
   return (ihigh_8);
}


int deinit() {
   return (0);
}


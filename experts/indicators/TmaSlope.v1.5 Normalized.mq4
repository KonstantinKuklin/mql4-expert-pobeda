//+------------------------------------------------------------------+
//|                                                     TmaSlope.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, zznbrm"

//Edited by shahrooz "sh.sadeghi.me@gmail.com"                           
//---- indicator settings
#property indicator_separate_window
#property  indicator_buffers 7
#property  indicator_level1 0.5
#property  indicator_level2 -0.5 

#property indicator_color1 Green
#property indicator_color2 Lime
#property indicator_color3 FireBrick
#property indicator_color4 Red
#property indicator_color5 DarkGray
#property indicator_color6 LightSlateGray
#property indicator_color7 NULL


#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2  
#property indicator_width6 2   
#property indicator_width7 0   


//---- input parameters
extern string OtherTimeFrames = "Select below 0=current tf,1,5,15,30,60,240,1440,10080,43200";

extern int select_other_tf_to_show=15;
extern int H_Pos_MTF=1;
extern int V_Pos_MTF=50;
extern int        Font_Size_MTF              = 12;
extern int Corner_MTF=3;
 color      Font_Color_MTF              ;

//---- input parameters

extern bool show_2nd_MTF=true;
extern string OtherTimeFrame_2nd = "Select below 0=current tf,1,5,15,30,60,240,1440,10080,43200";

extern int select_2nd_tf_to_show=60;
extern int H_Pos_MTF_2nd=1;
extern int V_Pos_MTF_2nd=75;
extern int        Font_Size_MTF_2nd              = 12;
extern int Corner_MTF_2nd=3;
 color      Font_Color_MTF_2nd              ;

extern bool show_3rd_MTF=true;
extern string OtherTimeFrame_3rd = "Select below 0=current tf,1,5,15,30,60,240,1440,10080,43200";

extern int select_3rd_tf_to_show=240;
extern int H_Pos_MTF_3rd=1;
extern int V_Pos_MTF_3rd=100;
extern int        Font_Size_MTF_3rd              = 12;
extern int Corner_MTF_3rd=3;
 color      Font_Color_MTF_3rd              ;
extern int eintPeriod = 56;
extern double edblHigh1 = 0.5;
extern double edblLow1 = -0.5;
extern int atrPeriod = 100;


extern color      Font_Color          = White;
extern int        H_Pos               = 1;
extern int        V_Pos               = 25;
extern int        Corner              = 3;
extern int        Font_Size           = 14;
extern int        Font_Size_text      = 11;
extern int        H_Pos_text          = 1;
extern int        V_Pos_text          = 1;

extern int Text_Corner=3;

//---- indicator buffers
double gadblUp1[];
double gadblUp2[];

double gadblDn1[];
double gadblDn2[];

double gadblMid1[];
double gadblMid2[];

double gadblSlope[]; 
color Font_Color_M15;

double TICK;
bool AdditionalDigit;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{              
   //IndicatorBuffers( 8 );    
   IndicatorBuffers( 7 );
   IndicatorDigits( 5 );
   IndicatorShortName( "TmaSlope_Norm" );
   AdditionalDigit = MarketInfo(Symbol(), MODE_MARGINCALCMODE) == 0 && MarketInfo(Symbol(), MODE_PROFITCALCMODE) == 0 && Digits % 2 == 1;
   TICK = getTick();
      
   SetIndexBuffer( 0, gadblUp1 );    SetIndexLabel( 0, NULL );       SetIndexStyle( 0, DRAW_HISTOGRAM );
   SetIndexBuffer( 1, gadblUp2 );    SetIndexLabel( 1, NULL );       SetIndexStyle( 1, DRAW_HISTOGRAM );
   SetIndexBuffer( 2, gadblDn1 );    SetIndexLabel( 2, NULL );       SetIndexStyle( 2, DRAW_HISTOGRAM );
   SetIndexBuffer( 3, gadblDn2 );    SetIndexLabel( 3, NULL );       SetIndexStyle( 3, DRAW_HISTOGRAM );
   SetIndexBuffer( 4, gadblMid1 );    SetIndexLabel( 4, NULL );       SetIndexStyle( 4, DRAW_HISTOGRAM );
   SetIndexBuffer( 5, gadblMid2 );    SetIndexLabel( 5, NULL );       SetIndexStyle( 5, DRAW_HISTOGRAM );

   SetIndexBuffer( 6, gadblSlope );  SetIndexLabel( 6, "TMA Slope" );    SetIndexStyle( 6, DRAW_NONE );

      
   SetIndexEmptyValue( 0, 0.0 );
   SetIndexEmptyValue( 1, 0.0 );
   SetIndexEmptyValue( 2, 0.0 );


   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   if ( counted_bars < 0 ) return(-1);
   if ( counted_bars > 0 ) counted_bars--;
               
   int intLimit = MathMin( Bars - 1, Bars - counted_bars + eintPeriod );
   
   double dblTma, dblPrev;
      double dblTmaMTF, dblPrevMTF;
      double dblTmaMTF2, dblPrevMTF2;
      double dblTmaMTF3, dblPrevMTF3;
   double atr ; 
    double atrMTF;
    double atrMTF2;
    double atrMTF3;
   for( int inx = intLimit; inx >= 0; inx-- )
   {   
      //gadblTma[inx] = calcTma( inx );
      //gadblPrev[inx] = calcTma( inx+1 );
      //gadblSlope[inx] = ( gadblTma[inx] - gadblPrev[inx] ) / TICK;
      atr= iATR(NULL,0,atrPeriod,inx+10)*0.1;
      atrMTF= iATR(NULL,select_other_tf_to_show,atrPeriod,inx+10)*0.1;
      atrMTF2= iATR(NULL,select_2nd_tf_to_show,atrPeriod,inx+10)*0.1;
      atrMTF3= iATR(NULL,select_3rd_tf_to_show,atrPeriod,inx+10)*0.1;
      if (atr == 0) continue;
      if (atrMTF == 0) continue;
      if (atrMTF2 == 0) continue;
      if (atrMTF3 == 0) continue;
      dblTma = calcTma( inx );
      dblPrev = calcTma( inx+1 );
      gadblSlope[inx] = ( dblTma - dblPrev ) / atr;
      
      gadblUp1[inx] = 0.0;   
      gadblDn1[inx] = 0.0;     
      gadblMid1[inx] = 0.0;   
      gadblUp2[inx] = 0.0;   
      gadblDn2[inx] = 0.0;     
      gadblMid2[inx] = 0.0;   
   
     if ( gadblSlope[inx] > edblHigh1 )
     {
         if(gadblSlope[inx] < gadblSlope[inx+1]) gadblUp1[inx] = gadblSlope[inx];
         else gadblUp2[inx] = gadblSlope[inx];
     }
     else if ( gadblSlope[inx] < edblLow1 )
     {
         if(gadblSlope[inx] < gadblSlope[inx+1]) gadblDn2[inx] = gadblSlope[inx];
         else gadblDn1[inx] = gadblSlope[inx];
     }
     else  
     {
         if(gadblSlope[inx] < gadblSlope[inx+1]) gadblMid2[inx] = gadblSlope[inx];
         else gadblMid1[inx] = gadblSlope[inx];
     } 
   
 //  if(gadblSlope[inx]>=0 && gadblSlope[inx]<gadblSlope[inx+1] && Close[inx]>Open[inx] ) arrowdown[inx]=gadblSlope[inx]+0.1*gadblSlope[inx]; 
 //  if(gadblSlope[inx]<0 && gadblSlope[inx]>gadblSlope[inx+1] && Close[inx]<Open[inx]&& gadblSlope[inx+2]>=gadblSlope[inx+1]) arrowup[inx]=gadblSlope[inx]+0.1*gadblSlope[inx]; 

     string tt=DoubleToStr(gadblSlope[inx],2);

    ObjectCreate("label",OBJ_LABEL,WindowFind("TmaSlope_Norm"),0,0);
    ObjectSet("label",OBJPROP_XDISTANCE,H_Pos);
    ObjectSet("label",OBJPROP_YDISTANCE,V_Pos);
    ObjectSet("label",OBJPROP_CORNER,Corner);
    ObjectSetText("label"," "+tt+" ",Font_Size,"Arial",Font_Color);
   
    string sObjName="InfoBar1";
    string sObjName2="InfoBar2";
    string sObjName3="InfoBar3";
   if (gadblSlope[0] >= edblHigh1)
      ObjectSetText(sObjName, "Buy Only", Font_Size_text, "Verdana", YellowGreen);
   
   else if (gadblSlope[0] <= edblLow1)
      ObjectSetText(sObjName, "Sell Only", Font_Size_text, "Verdana", Red);
   
   else 
      ObjectSetText(sObjName, "Ranging", Font_Size_text, "Verdana", DarkGray);
      
   
   string name1 = "InfoBar1";
   
   switch(select_other_tf_to_show)
   {
      case 1 : string TimeFrameStr="M1"; break;
      case 5 : TimeFrameStr="M5"; break;
      case 15 : TimeFrameStr="M15"; break;
      case 30 : TimeFrameStr="M30"; break;
      case 60 : TimeFrameStr="H1"; break;
      case 240 : TimeFrameStr="H4"; break;
      case 1440 : TimeFrameStr="D1"; break;
      case 10080 : TimeFrameStr="W1"; break;
      case 43200 : TimeFrameStr="MN1"; break;
      default : TimeFrameStr="Current";
   } 
   
    switch(select_2nd_tf_to_show)
   {
      case 1 : string TimeFrameStr2="M1"; break;
      case 5 : TimeFrameStr2="M5"; break;
      case 15 : TimeFrameStr2="M15"; break;
      case 30 : TimeFrameStr2="M30"; break;
      case 60 : TimeFrameStr2="H1"; break;
      case 240 : TimeFrameStr2="H4"; break;
      case 1440 : TimeFrameStr2="D1"; break;
      case 10080 : TimeFrameStr2="W1"; break;
      case 43200 : TimeFrameStr2="MN1"; break;
      default : TimeFrameStr2="Current";
   }
   
      switch(select_3rd_tf_to_show)
   {
      case 1 : string TimeFrameStr3="M1"; break;
      case 5 : TimeFrameStr3="M5"; break;
      case 15 : TimeFrameStr3="M15"; break;
      case 30 : TimeFrameStr3="M30"; break;
      case 60 : TimeFrameStr3="H1"; break;
      case 240 : TimeFrameStr3="H4"; break;
      case 1440 : TimeFrameStr3="D1"; break;
      case 10080 : TimeFrameStr3="W1"; break;
      case 43200 : TimeFrameStr3="MN1"; break;
      default : TimeFrameStr3="Current";
   }
   
   ObjectCreate(sObjName, OBJ_LABEL,WindowFind("TmaSlope_Norm"), 0, 0);
   ObjectSet(sObjName, OBJPROP_CORNER, Text_Corner);
   ObjectSet(sObjName, OBJPROP_XDISTANCE, H_Pos_text);//left to right
   ObjectSet(sObjName, OBJPROP_YDISTANCE, V_Pos_text);//top to bottom

    dblTmaMTF = calcTmaMTF( 0 , select_other_tf_to_show );
      dblPrevMTF = calcTmaMTF( 1 , select_other_tf_to_show);
      double hh = ( dblTmaMTF - dblPrevMTF ) / atrMTF;
if(hh>=0.5) Font_Color_MTF=YellowGreen;
else if (hh<=-0.5) Font_Color_MTF=Red;
else Font_Color_MTF=DarkGray;
string jj=DoubleToStr(hh,2);
    ObjectCreate("label MTF",OBJ_LABEL,WindowFind("TmaSlope_Norm"),0,0);
    ObjectSet("label MTF",OBJPROP_XDISTANCE,H_Pos_MTF);
    ObjectSet("label MTF",OBJPROP_YDISTANCE,V_Pos_MTF);
    ObjectSet("label MTF",OBJPROP_CORNER,Corner_MTF);
   ObjectSetText("label MTF",""+TimeFrameStr+" = "+jj+" ",Font_Size_MTF,"Arial",Font_Color_MTF);
   
   
   
 if(show_2nd_MTF)
{
    dblTmaMTF2 = calcTmaMTF( 0 , select_2nd_tf_to_show );
      dblPrevMTF2 = calcTmaMTF( 1 , select_2nd_tf_to_show);
      double ii = ( dblTmaMTF2 - dblPrevMTF2 ) / atrMTF2;
if(ii>=0.5) Font_Color_MTF_2nd=YellowGreen;
else if (ii<=-0.5) Font_Color_MTF_2nd=Red;
else Font_Color_MTF_2nd=DarkGray;
string oo=DoubleToStr(ii,2);
    ObjectCreate("label MTF_2nd",OBJ_LABEL,WindowFind("TmaSlope_Norm"),0,0);
    ObjectSet("label MTF_2nd",OBJPROP_XDISTANCE,H_Pos_MTF_2nd);
    ObjectSet("label MTF_2nd",OBJPROP_YDISTANCE,V_Pos_MTF_2nd);
    ObjectSet("label MTF_2nd",OBJPROP_CORNER,Corner_MTF_2nd);
   ObjectSetText("label MTF_2nd",""+TimeFrameStr2+" = "+oo+" ",Font_Size_MTF_2nd,"Arial",Font_Color_MTF_2nd);
   }
   else ObjectDelete("label MTF_2nd");
   if(show_3rd_MTF)
   {
   
    dblTmaMTF3 = calcTmaMTF( 0 , select_3rd_tf_to_show );
      dblPrevMTF3 = calcTmaMTF( 1 , select_3rd_tf_to_show);
      double qq = ( dblTmaMTF3 - dblPrevMTF3 ) / atrMTF3;
if(qq>=0.5) Font_Color_MTF_3rd=YellowGreen;
else if (qq<=-0.5) Font_Color_MTF_3rd=Red;
else Font_Color_MTF_3rd=DarkGray;
string ww=DoubleToStr(qq,2);
    ObjectCreate("label MTF_3rd",OBJ_LABEL,WindowFind("TmaSlope_Norm"),0,0);
    ObjectSet("label MTF_3rd",OBJPROP_XDISTANCE,H_Pos_MTF_3rd);
    ObjectSet("label MTF_3rd",OBJPROP_YDISTANCE,V_Pos_MTF_3rd);
    ObjectSet("label MTF_3rd",OBJPROP_CORNER,Corner_MTF_3rd);
   ObjectSetText("label MTF_3rd",""+TimeFrameStr3+" = "+ww+" ",Font_Size_MTF_3rd,"Arial",Font_Color_MTF_3rd);
   }
   else ObjectDelete("label MTF_3rd");
     }
   return( 0 );
}

//+------------------------------------------------------------------+
//| getTick()                                                        |
//+------------------------------------------------------------------+
double getTick() {
    double tick = MarketInfo(Symbol(), MODE_TICKSIZE);
    if (AdditionalDigit) {
        tick *= 10;
    }    
    return (tick);
}

//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma( int inx )
{
   double dblSum  = (eintPeriod+1)*Close[inx];
   double dblSumw = (eintPeriod+1);
   int jnx, knx;
         
   for ( jnx = 1, knx = eintPeriod; jnx <= eintPeriod; jnx++, knx-- )
   {
      dblSum  += ( knx * Close[inx+jnx] );
      dblSumw += knx;

      if ( jnx <= inx )
      {
         dblSum  += ( knx * Close[inx-jnx] );
         dblSumw += knx;
      }
   }
   
   return( dblSum / dblSumw );
}
 
 
 double calcTmaMTF( int inx , int tf)
{
   double dblSum  = (eintPeriod+1)*iClose(Symbol(),tf,inx);
   double dblSumw = (eintPeriod+1);
   int jnx, knx;
         
   for ( jnx = 1, knx = eintPeriod; jnx <= eintPeriod; jnx++, knx-- )
   {
      dblSum  += ( knx * iClose(Symbol(),tf,inx+jnx) );
      dblSumw += knx;

      if ( jnx <= inx )
      {
         dblSum  += ( knx * iClose(Symbol(),tf,inx-jnx) );
         dblSumw += knx;
      }
   }
   
   return( dblSum / dblSumw );
}
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 



   



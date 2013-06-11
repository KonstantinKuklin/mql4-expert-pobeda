#property copyright "Extreme TMA System"
#property link      "http://www.forexfactory.com/showthread.php?t=343533m"

#property indicator_chart_window
#property indicator_buffers    6
#property indicator_color1     CLR_NONE
#property indicator_color2     White
#property indicator_color3     White
#property indicator_color4     Lime 
#property indicator_color5     Red
#property indicator_color6     White
#property indicator_style2     STYLE_DOT
#property indicator_style3     STYLE_DOT
#property  indicator_width1 1
#property  indicator_width2 1
#property  indicator_width3 1
#property  indicator_width4 1
#property  indicator_width5 1
#property  indicator_width6 1


extern string TimeFrame       = "Current";
extern int    TMAPeriod      = 56;
extern int    Price           = PRICE_CLOSE;
extern double ATRMultiplier   = 2.0;
extern int    ATRPeriod       = 100;
extern double TrendThreshold = 0.5;
extern bool ShowCenterLine = false;


extern bool   alertsOn        = false;
extern bool   alertsMessage   = false;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

double tma[];
double upperBand[];
double lowerBand[];
double bull[];
double bear[];
double neutral[];
 
int    TimeFrameValue;
bool AlertHappened;
datetime AlertTime;
double TICK;
bool AdditionalDigit;


int init()
{
   AdditionalDigit = MarketInfo(Symbol(), MODE_MARGINCALCMODE) == 0 && MarketInfo(Symbol(), MODE_PROFITCALCMODE) == 0 && Digits % 2 == 1;
   
    TICK = MarketInfo(Symbol(), MODE_TICKSIZE);
    if (AdditionalDigit) {
        TICK *= 10;
    }     
    
   TimeFrameValue         = stringToTimeFrame(TimeFrame);
                
                 
   IndicatorBuffers(6); 
   SetIndexBuffer(0,tma); SetIndexDrawBegin(0,TMAPeriod * (TimeFrameValue / Period()) );
   SetIndexBuffer(1,upperBand); SetIndexDrawBegin(1,TMAPeriod* (TimeFrameValue / Period()));
   SetIndexBuffer(2,lowerBand); SetIndexDrawBegin(2,TMAPeriod* (TimeFrameValue / Period()));
   SetIndexBuffer(3,bull); SetIndexDrawBegin(3,TMAPeriod* (TimeFrameValue / Period()));
   SetIndexBuffer(4,bear); SetIndexDrawBegin(4,TMAPeriod* (TimeFrameValue / Period()));
   SetIndexBuffer(5,neutral); SetIndexDrawBegin(5,TMAPeriod* (TimeFrameValue / Period()));
   
   IndicatorShortName(TimeFrameValueToString(TimeFrameValue)+" TMA bands ("+TMAPeriod+")");
   return(0);
}
int deinit() { return(0); }


int start()
{
   int counted_bars=IndicatorCounted();
   int i,j,k,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   double barsPerTma = (TimeFrameValue / Period());
   limit=MathMin(Bars-1,Bars-counted_bars+ TMAPeriod * barsPerTma ); 

   int mtfShift = 0;
   int lastMtfShift = 999;
   double tmaVal = tma[limit+1];
   double range = 0;
   
   double slope = 0;
   double prevTma = tma[limit+1];
   double prevSlope = 0;
   
   
   for (i=limit; i>=0; i--)
   {
      if (TimeFrameValue == Period())
      {
         mtfShift = i;
      }
      else
      {         
         mtfShift = iBarShift(Symbol(),TimeFrameValue,Time[i]);
      } 
      
      if(mtfShift == lastMtfShift)
      {       
         tma[i] =tma[i+1] + ((tmaVal - prevTma) * (1/barsPerTma));         
         upperBand[i] =  tma[i] + range;
         lowerBand[i] = tma[i] - range;
         DrawCenterLine(i, slope);   
         continue;
      }
      
      lastMtfShift = mtfShift;
      prevTma = tmaVal;
      tmaVal = CalcTma(mtfShift);
      
      range = iATR(NULL,TimeFrameValue,ATRPeriod,mtfShift+10)*ATRMultiplier;
      if(range == 0) range = 1;
      
      if (barsPerTma > 1)
      {
         tma[i] =prevTma + ((tmaVal - prevTma) * (1/barsPerTma));
      }
      else
      {
         tma[i] =tmaVal;
      }
      upperBand[i] = tma[i]+range;
      lowerBand[i] = tma[i]-range;

      slope = (tmaVal-prevTma) / ((range / ATRMultiplier) * 0.1);
            
      DrawCenterLine(i, slope);
          
   }
   
   manageAlerts();
   return(0);
}

void DrawCenterLine(int shift, double slope)
{

   bull[shift] = EMPTY_VALUE;
   bear[shift] = EMPTY_VALUE;          
   neutral[shift] = EMPTY_VALUE; 
   if (ShowCenterLine)
   {
      if(slope > TrendThreshold)
      {
         bull[shift] = tma[shift];
      }
      else if(slope < -1 * TrendThreshold)
      {
         bear[shift] = tma[shift];
      }
      else
      {
         neutral[shift] = tma[shift];
      }
   }
}

 double CalcTma( int inx )
{ 
   double dblSum  = (TMAPeriod+1)*iClose(Symbol(),TimeFrameValue,inx);
   double dblSumw = (TMAPeriod+1);
   int jnx, knx;
         
   for ( jnx = 1, knx = TMAPeriod; jnx <= TMAPeriod; jnx++, knx-- )
   {
      dblSum  += ( knx * iClose(Symbol(),TimeFrameValue,inx+jnx) );
      dblSumw += knx;      
      
      if ( jnx <= inx )
      {         
         if (iTime(Symbol(),TimeFrameValue,inx-jnx) > Time[0])
         {
            //Print (" TimeFrameValue ", TimeFrameValue , " inx ", inx," jnx ", jnx, " iTime(Symbol(),TimeFrameValue,inx-jnx) ", TimeToStr(iTime(Symbol(),TimeFrameValue,inx-jnx)), " Time[0] ", TimeToStr(Time[0])); 
            continue;
         }
         dblSum  += ( knx * iClose(Symbol(),TimeFrameValue,inx-jnx) );
         dblSumw += knx;
      }
   }
   
   return( dblSum / dblSumw );
}
 

void manageAlerts()
{
   if (alertsOn)
   { 
      int trend;        
      if (Close[0] > upperBand[0]) trend =  1;
      else if (Close[0] < lowerBand[0]) trend = -1;
      else {AlertHappened = false;}
            
      if (!AlertHappened && AlertTime != Time[0])
      {       
         if (trend == 1) doAlert("up");
         if (trend ==-1) doAlert("down");
      }         
   }
}


void doAlert(string doWhat)
{ 
   if (AlertHappened) return;
   AlertHappened = true;
   AlertTime = Time[0];
   string message;
     
   message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," "+TimeFrameValueToString(TimeFrameValue)+" TMA bands price penetrated ",doWhat," band");
   if (alertsMessage) Alert(message);
   if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"TMA bands "),message);
   if (alertsSound)   PlaySound("alert2.wav");

}

//+-------------------------------------------------------------------
//|   Time Frame Handlers                                                               
//+-------------------------------------------------------------------


string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};


int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
   {
      if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) 
      {
         return(MathMax(iTfTable[i],Period()));
      }
   }
   return(Period());
   
}
string TimeFrameValueToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int char = StringGetChar(s, length);
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                     s = StringSetChar(s, length, char - 32);
         else if(char > -33 && char < 0)
                     s = StringSetChar(s, length, char + 224);
   }
   return(s);
}
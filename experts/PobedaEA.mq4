//
// Советнмк по стратегии "Победа версия 1" с форума tradelikeapro.ru от Skylover410
//
#property copyright "EURUSD-M1 (c) dev by Graybit"
#property link      "konstantin.kuklin@gmail.com"


//////////////// DEFINE CONFIG
#define UP      1
#define MIDDLE  0
#define DOWN   -1

//////////////// EXTERNAL VARIABLES
extern bool   extUseMoneyManager = false;
extern int    extRiskPercent     = 3;
extern double extFixLotSize      = 0.01;
extern bool   extIsTest          = false;
extern bool   extShowComment     = true;
extern bool   extUseTrail        = false;
//////////
extern bool   extIntellectualStopLoss = false; 
extern int    extTakeProfitPips        = 50;
extern int    extStopLossPips          = 150;
extern double extTrailingStop = 8.0;
extern double extTrailingStep = 1.0;
extern int    extMagicNumber = 4371;
//////////
extern bool tradeOnlyInTime = false;   
extern int  gmtshift        = -1;                   // gmt offset
extern int  StartHour       = 10;
extern int  StartMinute     = 10;
extern int  EndHour         = 21;
extern int  EndMinute       = 0;

extern string  Comment_NewsFilter = "Фильтр торговли во время новостей";
extern bool    UseNewsFilter      = true;
extern int     MinsBeforeNews     = 10; // mins before an event to stay out of trading
extern int     MinsAfterNews      = 20; // mins after  an event to stay out of trading
extern bool 	IncludeHigh 		 = true;
extern bool 	IncludeMedium 		 = true;
extern bool 	IncludeLow 			 = false;
extern bool 	IncludeSpeaks 		 = true; 		// news items with "Speaks" in them have different characteristics

//////////////// VARIABLES
extern int extNeedTmaSize = 100; // Pips

bool NewsTime          = false,
     IncludeOpenEquity = true
;

int minutesUntilNextEvent = 0,
    minutesSincePrevEvent = 0,

    myOrdersList[],
    tmaM1VectorSmall,tmaM1VectorBig,
    newsLastMinuteCheck   = -1,
    screenShotLastMinuteCheck = -1,
    currentOrder,
    orderOpenMinute
;

// start variables for calculateNewVariables()
double valSSRC[6],
       spreadSize,
       
       tmaM1Size, tmaTrand, tmaM1Up[6],tmaM5Size,
       tmaM1Down[6],
       macd[6],
       tmaM1Middle,tmaM1Middle10,tmaM1Middle70,
       tmaM5Middle,tmaM5Middle4,
       tmaM5Up[6],tmaM5Down[6],
       kanal,
       USDPower, EURPower,
       ma170, ma50, ma50Shift5
;
double gd_100; // for trailing

string TrendInfo;
// end variables for calculateNewVariables()

bool  buyVector,
      buyImaToClose,
      buyTouch,
      buySSRC,
      buyTmaSize,
      buyPower,
      buyM5,
      buyNeedPips,
      buyMacd,
      buyBigBar,
      buyMa50Shift,
      
      sellVector,
      sellImaToClose,
      sellTouch,
      sellSSRC,
      sellTmaSize,
      sellPower,
      sellM5,
      sellNeedPips,
      sellMacd,
      sellBigBar,
      sellMa50Shift
;     

bool stopLossModify  = false,
     stopLossModify2 = false,
     stopLossModify10 = false,
     stopLossModify25 = false;
     
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() { 
   gd_100 = Point;
   if (Digits == 5 || Digits == 3) {
      gd_100 = 10.0 * gd_100;
   }
   
   spreadSize = MathAbs(Bid-Ask) / Point;
   return(0); 
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() { return(0); }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

bool globalTrade = false;
int start()
{
   double lotSize;
   
   RefreshRates();
   getMyOrders(myOrdersList);
   
   calculateNewVariables();
   // Если у нас есть открытые Позиции
   if(ArraySize(myOrdersList) > 0){
      if(extUseTrail){
         modifyStopLoss();
      }
      //checkToClose();
   }else{
      stopLossModify  = false;
      stopLossModify2 = false;
      stopLossModify10 = false;
      stopLossModify25 = false;
     
      // Если позиций открытых нет
      lotSize = calculateLotSize();
      if(lotSize == 0){
         Print("No money");
         return(0);
      }
      
      globalTrade = false;
      // Глобальные условия для торговли
      if(isTradeTime() && isNoNews()){
         
         globalTrade = true;
         //Print("Yes");
         if(isPobedaGoodPositionToBuy()){
            // Входим в покупки
            openBuyOrder(lotSize);
            //Print("Buy");
         }else if(isPobedaGoodPositionToSell()){
            // Входим в продажи
            openSellOrder(lotSize);
            //Print("Sell");
         }  
      }
   }
      
   

   if(extShowComment) {
      Comment(" \nPobeda by Graybit v0.01", 
         "\nСерверное время" + TimeToStr(TimeCurrent(), TIME_SECONDS) + " (GMT: "+TimeToStr(TimeCurrent()-gmtshift*3600, TIME_SECONDS)+")", 
         "\nТорговое время: " + boolToStr(isTradeTime()),
         "\nОткрытые ордера: "+boolToStr(ArraySize(myOrdersList)),
         "\nВход в торговлю: "+boolToStr(globalTrade),
         "\nРазмер лота: "+DoubleToStr(calculateLotSize(),2),
            
         "\n\nВектор на покупку: "+boolToStr(buyVector),
         "\nКасание нижнего уровня: "+boolToStr(buyTouch),
         "\nSSRC на покупку: "+boolToStr(buySSRC),
         "\nTMA размер: "+boolToStr(buyTmaSize),
         "\nЕвро сильнее Доллара: "+boolToStr(buyPower),
         "\nНа М5 цена ниже середины: "+boolToStr(buyM5),
         "\nДо верхнего уровня пипсов достаточно: "+boolToStr(buyNeedPips),
         "\nMacd buy: "+boolToStr(buyMacd),
      
         "\n\nВектор на продажу: "+boolToStr(sellVector),
         "\nКасание верхнего уровня: "+boolToStr(sellTouch),
         "\nSSRC на продажу: "+boolToStr(sellSSRC),
         "\nTMA размер: "+boolToStr(sellTmaSize),
         "\nЕвро слабее Доллара: "+boolToStr(sellPower),
         "\nНа М5 цена выше середины: "+boolToStr(sellM5),
         "\nДо нижнего уровня пипсов достаточно: "+boolToStr(sellNeedPips),
         "\nMacd sell: "+boolToStr(sellMacd),
      
         "\n");
   }
   
   //iCustom(NULL, 0, "Screnshoter", 0, 0);
   return(0);
}
//+------------------------------------------------------------------+

// Проверяем, нужно ли закрывать уже открытую сделку
int checkToClose(){
   // Фиксим время, переход с 60 на 0
   if(orderOpenMinute - 20 > Minute()){
      orderOpenMinute = orderOpenMinute - 60;
   }

   // Если не прошло еще 4 минуты
   if(orderOpenMinute + 4 > Minute()){
      return(0);
   }
   // Если сделка на продажу
   if(OrderType()==OP_SELL){
      if(!(macd[1] < macd[2] && macd[2] < macd[3])){
         OrderClose(OrderTicket(), OrderLots(), Ask,3,Red);
      }
   }else{ 
      if(!(macd[1] > macd[2] && macd[2] > macd[3])){
         OrderClose(OrderTicket(), OrderLots(), Bid,3,Red);
      }
   }
}
     
void modifyStopLoss(){
   
   // Включаем тралинье, если уже достигнуто 50 пипсов профита
   if(stopLossModify25){
      realTrailOrder();
   }else{
      
      // Если сделка на продажу
      if(OrderType()==OP_SELL){
         if(!stopLossModify25 && (OrderOpenPrice() - Close[0]) / Point > extTakeProfitPips) { // Если профит больше extTakeProfitPips, включаем трал
            stopLossModify25 = true;
         }
      }else{ 
         if(!stopLossModify25 && (Close[0] - OrderOpenPrice()) / Point > extTakeProfitPips) { // Если профит больше extTakeProfitPips, включаем трал
            stopLossModify25 = true;
         }
      }
   }
}


bool isPobedaGoodPositionToBuy(){
   buyVector = true;
   buyImaToClose = true;
   buyTouch = true;
   buySSRC = true;
   buyTmaSize = true;
   buyPower = true;
   buyM5 = true;
   buyNeedPips = true;
   buyMacd = true;
   buyBigBar = true;
   buyMa50Shift = true;

   bool trade = true;
   //Вход на покупку:
   if(tmaM1Middle < tmaM1Middle10){
      trade = false;
      buyVector = false;
   }

   
   //2) Цена коснулась нижней линии ТМА и начала разворачиваться
   bool touch = false;
   for(int i=0; i < 6; i++){
      if(Low[i] - (3 * Point) <= tmaM1Down[i]){ // 3 поинта считаем тоже за касание
         touch = true;
         //Print(Low[i] + "-" + (3 * Point) +"-"+ tmaM1Down[i]);
      }
   }
   if(!touch){
      trade = false;
      buyTouch = false;
   }
   
   //
   if(!(valSSRC[3] <= -0.75 && valSSRC[2] <= -0.75 && valSSRC[0] > -0.75) //3) SSRC — появилась стрелочка вверх
   || !(valSSRC[3] <= -0.9 && valSSRC[2] <= -0.9 && valSSRC[0] > -0.9)
   || !(valSSRC[3] <= -0.75 && valSSRC[2] <= -0.75 && valSSRC[0] > -0.9)   
   ){
      trade = false;
      buySSRC = false;
   }

   //4) Ширина ТМA больше или равна 10 пунктов
   if(tmaM1Size < extNeedTmaSize
      //(tmaM1Up[0] - Close[0]) / Point < 100 + (spreadSize / 2) // Если цена закрытия не дает канал необходимый
   ) {
      trade = false;
      buyTmaSize = false;
   }
   //5) Currency Power Meter: сила евро больше или равна силе доллара.
   if(EURPower < USDPower && !extIsTest){
      trade = false;
      buyPower = false;
   }
   //6) СЛ=15, ТП=5
   // готово!
   
   //7) На м5 цена находится в нижней части канала ТМА, либо на середине. Но никак не возле верхней линии TMA.
   if(Close[0] > tmaM5Middle && !extIsTest){
      trade = false;
      buyM5 = false; 
   }
   /*
   //8) До противоположной границы больше чем профитных пипсов и размера спреда
   if(tmaM1Up[0] - Close[0] < (spreadSize + 50) * Point){
      trade = false;
      buyNeedPips = false;
   }
   */
   
   // Если macd уменьшается, то покупать нельзя
   if(macd[0] < macd[1]){
      trade = false;
      buyMacd = false;
   }
   
   return(trade);
}

// проверяем можно ли войти в сделку
bool isPobedaGoodPositionToSell(){

   sellVector = true;
   sellImaToClose = true;
   sellTouch = true;
   sellSSRC = true;
   sellTmaSize = true;
   sellPower = true;
   sellM5 = true;
   sellNeedPips = true;
   sellMacd = true;
   sellBigBar = true;
   sellMa50Shift = true;

   bool trade = true;
   //Вход на продажу:
   //1) ТМА на м1 направлен вниз, либо горизонтален
   if(tmaM1Middle > tmaM1Middle10){
      trade = false;
      sellVector = false;
   }

   //2) Цена коснулась верхней линии ТМА и начала разворачиваться
   bool touch = false;
   for(int i=0; i < 6; i++){
      if(High[i] + (3 * Point) >= tmaM1Up[i]){ // 3 Поинта уже считаем касанием
         touch = true;
         //Print(High[i] + "-" + (3 * Point) +"-"+ tmaM1Up[i]);
      }
   }
   if(!touch){
      trade = false;
      sellTouch = false;
   }
   
   //
   if(!(valSSRC[3] > 0.75 && valSSRC[2] > 0.75 && valSSRC[0] < 0.75)
   || !(valSSRC[3] > 0.9 && valSSRC[2] > 0.9 && valSSRC[0] < 0.9)
   || !(valSSRC[3] > 0.75 && valSSRC[2] > 0.75 && valSSRC[0] < 0.9)
    //3) SSRC — появилась стрелочка вниз
   //   && !((valSSRC[0] >= 0.9 && valSSRC[1] >= 0.9) && (Close[0] - (10 * Point) > tmaM1Up[0])) // Форсированный режим, если закрылась сделка выше уровня тма
   ){
      trade = false;
      sellSSRC = false;
   }
   
   //4) Ширина ТМA больше или равна 10 пунктов
   if(tmaM1Size < extNeedTmaSize 
     //(Close[0] - tmaM1Down[0]) / Point < 100 + (spreadSize / 2) // Если цена закрытия не дает канал необходимый
   ) {
      trade = false;
      sellTmaSize = false;
   }
   //5) Currency Power Meter: сила евро меньше или равна силе доллара.
   if(EURPower > USDPower && !extIsTest){
      trade = false;
      sellPower = false;
   }
   //6) СЛ=15, ТП=5
   // готово!
   
   //7) На м5 цена находится в верхней части канала ТМА, либо на середине. Но никак не возле нижней линии TMA.
   if(Close[0] < tmaM5Middle){
      trade = false;
      sellM5 = false;
   }
   /*
   //8) До противоположной границы больше чем профитных пипсов и размера спреда
   if(Close[0]-tmaM1Down[0] < (spreadSize + 50) * Point){
      trade = false;
      sellNeedPips = false;
   }
   */
   
   // Если macd увеличивается, то продавать нельзя
   if(macd[0] > macd[1]){
      trade = false;
      sellMacd = false;
   }
   
   return(trade);
}

// Открываем сделку на покупку
void openBuyOrder(double lotSize){
   double stop,take = 0;

   orderOpenMinute = Minute();
   if(!extIntellectualStopLoss) {
      stop = getNormalizeDouble(Bid - (extStopLossPips * Point));
      take = getNormalizeDouble(Ask + ((extTakeProfitPips) * Point));
   }else{
      // Берем наименьшее значение
      int lowBar = iLowest(NULL,PERIOD_M1,MODE_LOW, 15, 0);
      stop = Low[lowBar] - 10 * Point;
      
         //
      if((Bid - stop) / Point < 20 || (Bid - stop) / Point > extStopLossPips){
         stop = getNormalizeDouble(Bid - (extStopLossPips * Point));
      }
   }
   
   OrderSend(Symbol(),OP_BUY, lotSize, Ask, 10, stop, take, "", extMagicNumber, 0, 0);
}

// Открываем сделку на продажи
void openSellOrder(double lotSize){
   double stop,take = 0;

   orderOpenMinute = Minute();
   if(!extIntellectualStopLoss) {
      stop = getNormalizeDouble(Ask + (extStopLossPips * Point));
      take = getNormalizeDouble(Bid - ((extTakeProfitPips) * Point));
   }else{
      // Берем наименьшее значение
      int highBar = iHighest(NULL,PERIOD_M1,MODE_HIGH, 15, 0);
      stop = High[highBar] + 10 * Point;

      // Если наибольшее меньше 20,то берем фиксированное
      if((stop - Ask) / Point < 20 || (stop - Ask) / Point > extStopLossPips){
         stop = getNormalizeDouble(Ask + (extStopLossPips * Point));
      }
   }
   
   OrderSend(Symbol(),OP_SELL, lotSize, Bid, 10, stop, take, "", extMagicNumber, 0, 0);
}

// Получаем новые значения для переменных
void calculateNewVariables(){

   for(int i=0;i < 6;i++){
   
      macd[i] = iCustom(NULL,PERIOD_M1,"MACD",0,i) * 1000;
      //Print(macd[i]);
   
      tmaM1Up[i] = iCustom(NULL,PERIOD_M1,"TMA with Distances",
                     "current time frame", 56, 0, 2.8, 100, true, false, false, false, false,false,false, 1,i);
      tmaM1Down[i] = iCustom(NULL,PERIOD_M1,"TMA with Distances",
                     "current time frame", 56, 0, 2.8, 100, true, false, false, false, false,false,false, 2,i); 
      tmaM5Up[i] = iCustom(NULL,PERIOD_M5,"TMA with Distances", 
                     "current time frame", 56, 0, 2.8, 100, true, false, false, false, false,false,false, 1,i);
      tmaM5Down[i] = iCustom(NULL,PERIOD_M5,"TMA with Distances", 
                     "current time frame", 56, 0, 2.8, 100, true, false, false, false, false,false,false, 2,i);
      
      valSSRC[i]=iCustom(NULL, 0, "SSRC", 3, 21, 2, 6, 0,i);  
   }
   
//   ma170 = iCustom(NULL,PERIOD_M1,"Moving Averages", 170, 0, 3, 0,0);
//   ma50  = iCustom(NULL,PERIOD_M1,"Moving Averages",  50, 0, 3, 0,0);
   
//   ma50Shift5  = iCustom(NULL,PERIOD_M1,"Moving Averages",  50, 0, 3, 0,5);
   
   
   tmaM1Middle   = iCustom(NULL,PERIOD_M1,"TMA with Distances", 
                    "current time frame", 56, 0, 2.8, 100, true, false, false, false, false,false,false, 0,0);
   tmaM1Middle10 = iCustom(NULL,PERIOD_M1,"TMA with Distances", 
                    "current time frame", 56, 0, 2.8, 100, true, false, false, false, false,false,false, 0,20);                                   
   tmaM1Middle70 = iCustom(NULL,PERIOD_M1,"TMA with Distances", 
                    "current time frame", 56, 0, 2.8, 100, true, false, false, false, false,false,false, 0,40);
/*
   tmaM5Middle = iCustom(NULL,PERIOD_M5,"TMA with Distances", 
                  "current time frame", 56, 0, 2.8, 100, true, false, false, false, false,false,false, 0,0);
   tmaM5Middle70 = iCustom(NULL,PERIOD_M5,"TMA with Distances", 
                  "current time frame", 56, 0, 2.8, 100, true, false, false, false, false,false,false, 0,4);
*/
   tmaM1Size = (tmaM1Up[0] - tmaM1Down[0]) / Point;
   tmaM5Size = (tmaM5Up[0] - tmaM5Down[0]) / Point;
   
   
   if(tmaM1Middle > tmaM1Middle10){
      tmaM1VectorSmall = UP;
   }else{
      tmaM1VectorSmall = DOWN;
   }
   
   // Если вектор колеблется меньше от центровой линии, то считаем что можем в сделку входить в обе стороны
   if(MathAbs(tmaM1Middle10 - tmaM1Middle) / Point < 10){
      tmaM1VectorSmall = MIDDLE;
   }

   if(tmaM1Middle70 == tmaM1Middle){
      tmaM1VectorBig = MIDDLE;
   }
   
   if(tmaM1Middle > tmaM1Middle70){
      tmaM1VectorBig = UP;
   }else{
      tmaM1VectorBig = DOWN;
   }
   
   EURPower = iCustom(NULL,PERIOD_M1,"CurrencyPowerMeter_fixed_Graybit", 0,0);
   USDPower = iCustom(NULL,PERIOD_M1,"CurrencyPowerMeter_fixed_Graybit", 1,0);
   
} // end calculateNewVariables()

// Расчет объема ставки
double calculateLotSize(){   
   double balance, riskBalance, lot;
   
   // Если не включен режим расчета ставки, то берем фиксированное значение
   if(!extUseMoneyManager){
      return(extFixLotSize);
   }
   
   balance = AccountBalance();
   // при нулевом балансе возвращаем 0
   if(balance == 0){
      return(0);
   }
   
   // Кол-во бабла, которым мы готовы жертвовать
   riskBalance = balance * extRiskPercent / 100.0;
   lot = riskBalance / extStopLossPips;
   if(lot < 0.01) {
      lot = 0.01;
   }

   // Размер ставки, чтобы продолбать наше бабло под риск
   return(lot);
}

// Возвращает массив открытых сделок
int getMyOrders(int& variableList[]){
   int totalOrders = OrdersTotal();
   ArrayResize(variableList, totalOrders);
   
   int a=0;
   for( int i = 0 ; i < totalOrders ; i++ ){
      if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ){
         break;
      }else{
         currentOrder = i;
      }
        
      if( OrderMagicNumber() != extMagicNumber ){
         continue;
      }
      
      if( OrderSymbol() != Symbol() ){
         continue;
      }
      variableList[a] = i;
      a++;
   }
   
   return(variableList);
}

// Указанный временной этап соответствует ли нашему 
bool isTradeTime() {
   // Если можно торговать в любое время
   if(!tradeOnlyInTime){
      return(true);
   }
   
   int now = 60 * TimeHour(TimeCurrent()) + TimeMinute(TimeCurrent());
   int start = 60 * (StartHour+gmtshift) + StartMinute;
   int end = 60 * (EndHour+gmtshift) + EndMinute;
   
   if (start == end) {
      return (false);
   }else if (start < end) {
      if (!(!(now >= start && now < end))){ 
         return (true);
      }
      return (false);
   }else if (start > end) {
      if (!(!(now >= start || now < end))){ 
         return (true);
      }
      return (false);
   }
   
   return (false);
}

// Конвертируем int в да\нет
string boolToStr (int value) 
{
   if(value > 0){
      return ("Да");
   }
   
   return ("Нет");
}

// Проверяем, возможна ли торговля и нет ли событий в ближайшее время
bool isNoNews()
{
   if(extIsTest){
      return(true);
   }
   
   // Чекаем 1 раз в 5 минут
   if (Minute() + 5 > newsLastMinuteCheck || newsLastMinuteCheck  - 50 > Minute())
   {
      newsLastMinuteCheck = Minute() + 5;
      minutesSincePrevEvent =
         iCustom(NULL, 0, "FFCal-fix_by_stelz", IncludeHigh, IncludeMedium, IncludeLow, IncludeSpeaks, true, gmtshift, 1, 0);

      minutesUntilNextEvent =
         iCustom(NULL, 0, "FFCal-fix_by_stelz", IncludeHigh, IncludeMedium, IncludeLow, IncludeSpeaks, true, gmtshift, 1, 1);

      NewsTime = true;
      // Проверяем, если минут до события меньше или больше, чем указано, то отменяем торговлю
      if (
         minutesUntilNextEvent <= MinsBeforeNews || 
         minutesSincePrevEvent <= MinsAfterNews
      ) {
          NewsTime = false;
      }
   }
   
   return(NewsTime);
}// end checkNews()

// strailing stop function
void realTrailOrder() {
   double l_ord_open_price_20;
   double l_ord_stoploss_28;
   double l_price_36;
   double ld_0 = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point / gd_100;
   double ld_8 = MathMax(extTrailingStop, ld_0);
   
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      if (OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES) == TRUE) {
         if (OrderMagicNumber() == extMagicNumber || extMagicNumber < 0 && OrderSymbol() == Symbol()) {
            l_ord_open_price_20 = OrderOpenPrice();
            l_ord_stoploss_28 = OrderStopLoss();
            while (IsTradeContextBusy()) {
               Sleep(500);
            }
            RefreshRates();
            if (OrderType() == OP_BUY) {
               l_price_36 = getNormalizeDouble(Bid - ld_8 * gd_100);
               
               //Print("Bid:"+Bid +"|"+ l_ord_open_price_20 +"|"+ld_8 * gd_100);
               // Если текущая цена открытия больше, чем цена открытия ставки + пункты трейлинга(15) 
               if (Bid >= OrderStopLoss() + ((extTrailingStop + extTrailingStep) * Point)) {
                  if (!OrderModify(OrderTicket(), OrderOpenPrice(), Bid - getNormalizeDouble(extTrailingStop * Point), 0, 0, Blue)){
                     if (!IsOptimization()) {
                        Print("BUY OrderModify Error " + GetLastError());
                     }
                  }
               }
            }
            if (OrderType() == OP_SELL) {
               l_price_36 = getNormalizeDouble(Ask + ld_8 * gd_100);
               if (Ask <= OrderStopLoss() - ((extTrailingStop + extTrailingStep) * Point)) {
                  if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ask + getNormalizeDouble(extTrailingStop * Point), 0, 0, Red)){
                     if (!IsOptimization()) {
                        Print("Sell OrderModify Error " + GetLastError());
                     }
                  }
               }
            }
         }
      }
   }
}

double getNormalizeDouble(double ad_0) {
   return (NormalizeDouble(ad_0, Digits));
}

double toPips(double price){
   return(price / Point);
}

double toPrice(double pips){
   return(getNormalizeDouble(pips * Point));
}
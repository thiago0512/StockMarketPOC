public without sharing class TwelveDataApi {

    // API endpoint constants
    private static final String BASE_ENDPOINT = 'https://twelve-data1.p.rapidapi.com';
    private static final String RAPIDAPI_HOST = 'twelve-data1.p.rapidapi.com';
    private static final String RAPIDAPI_KEY = '4b5f1a42bbmshbe43ac6f8ec8c8dp138a6ajsn4a3e9448e04a';

    // Class to represent stock data
    public class Stock {
        @AuraEnabled public String symbol; // Stock symbol
        @AuraEnabled public String name; // Stock name
        @AuraEnabled public String exchange; // Stock exchange
        @AuraEnabled public String mic_code; // MIC code of the stock
        @AuraEnabled public String country; // Country of the stock
        @AuraEnabled public String type; // Type of stock
        @AuraEnabled public String figi_code; // FIGI code of the stock
        @AuraEnabled public Integer index; // Index to limit the number of stocks
    }
    
    // Class to represent time series data of a stock
    public class TimeSeries {
        @AuraEnabled public String datetimeValue; // Date and time of the data point
        @AuraEnabled public String open; // Open price
        @AuraEnabled public String high; // High price
        @AuraEnabled public String low; // Low price
        @AuraEnabled public String close; // Close price
        @AuraEnabled public String volume; // Trading volume
    }

    // Method to fetch NASDAQ stocks data
    @AuraEnabled(cacheable=true)
    public static List<Stock> getNasdaqStocks() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_ENDPOINT+ '/stocks?exchange=NASDAQ&format=json' ); // Set the API endpoint
        req.setMethod('GET'); // Set HTTP method
        req.setHeader('x-rapidapi-host', RAPIDAPI_HOST); // Set RapidAPI host header
        req.setHeader('x-rapidapi-key', RAPIDAPI_KEY); // Set RapidAPI key header

        Http http = new Http();
        HttpResponse res;
        
        try {
            res = http.send(req); // Send the HTTP request
            if (res.getStatusCode() == 200) { // Check if response status is OK
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> stocksData = (List<Object>) responseMap.get('data'); // Get stocks data from response
				Integer count = 1;
                List<Stock> stocks = new List<Stock>();
                for (Object stockObj : stocksData) {
                    if (count == 21) break; // Limit to 20 stocks
                    Map<String, Object> stockMap = (Map<String, Object>) stockObj;
                    Stock stock = new Stock();
                    stock.index = count;
                    stock.symbol = (String) stockMap.get('symbol');
                    stock.name = (String) stockMap.get('name');
                    stock.exchange = (String) stockMap.get('exchange');
                    stock.mic_code = (String) stockMap.get('mic_code');
                    stock.country = (String) stockMap.get('country');
                    stock.type = (String) stockMap.get('type');
                    stock.figi_code = (String) stockMap.get('figi_code');
                    stocks.add(stock); // Add stock to the list
                    count++;
                }
                return stocks; // Return the list of stocks
            } else {
                System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus()); // Log error if response is not OK
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage()); // Log any exceptions
            return null;
        }
    }
    
    // Method to fetch time series data for a specific stock symbol
    @AuraEnabled(cacheable=true)
    public static List<TimeSeries> getTimeSeriesData(String symbol) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_ENDPOINT + '/time_series?outputsize=10&symbol=' + symbol + '&interval=1day&format=json');
        req.setMethod('GET'); // Set HTTP method
        req.setHeader('x-rapidapi-host', RAPIDAPI_HOST); // Set RapidAPI host header
        req.setHeader('x-rapidapi-key', RAPIDAPI_KEY); // Set RapidAPI key header

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req); // Send the HTTP request
            if (res.getStatusCode() == 200) { // Check if response status is OK
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> timeSeriesData = (List<Object>) responseMap.get('values'); // Get time series data from response

                List<TimeSeries> timeSeriesList = new List<TimeSeries>();
                for (Object timeSeriesObj : timeSeriesData) {
                    Map<String, Object> timeSeriesMap = (Map<String, Object>) timeSeriesObj;
                    TimeSeries timeSeries = new TimeSeries();
                    timeSeries.datetimeValue = (String) timeSeriesMap.get('datetime');
                    timeSeries.open = (String) timeSeriesMap.get('open');
                    timeSeries.high = (String) timeSeriesMap.get('high');
                    timeSeries.low = (String) timeSeriesMap.get('low');
                    timeSeries.close = (String) timeSeriesMap.get('close');
                    timeSeries.volume = (String) timeSeriesMap.get('volume');
                    timeSeriesList.add(timeSeries); // Add time series data to the list
                }
                return timeSeriesList; // Return the list of time series data
            } else {
                System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus()); // Log error if response is not OK
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage()); // Log any exceptions
            return null;
        }
    }
}

class WeatherIcon extends StatelessWidget {  
 final String condition; // "sunny", "rainy", etc  
 @override  
 Widget build(BuildContext context) {  
 return Icon(  
 condition == 'sunny' ? Icons.sunny : Icons.cloud,   size: 80,  
 );  
 }  
}  
// Uso en cualquier pantalla:  
WeatherIcon(condition: 'sunny')

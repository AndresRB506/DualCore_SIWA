#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main(){
  string nombre;
  //Se crea un fichero
  ofstream fs("nombre.txt");

  //Capturando el nombre del archivo, ingresado por medio del teclado
  cout << "Ingrese el nombre del archivo a subir: " << endl;
  getline(cin, nombre);

  //Escribiendo el nombre del archivo en un fichero
  fs << nombre << endl;
  //Se cierra el fichero
  fs.close();

  return 0;
}

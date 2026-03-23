# finBrain

Proyecto Flutter con Firebase Auth + Google Sign-In

## Requisitos

- Flutter instalado
- Android Studio instalado
- Cuenta Firebase configurada

## Pasos para correr

```cmd
git clone https://github.com/JosueDJ20212015/finbrain.git
cd finbrain;
```

```cmd
flutter pub get
flutter run
```

## IMPORTANTE

Cada miembro debe agregar su SHA1 en Firebase

Comando para obtener SHA1 desde la terminal de windows:

```keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android```

Luego agregar en Firebase → Project settings → Android → Add SHA1

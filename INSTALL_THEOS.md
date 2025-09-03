# Установка Theos

## 1. Установка Theos

```bash
# Клонируем Theos
git clone --recursive https://github.com/theos/theos.git $HOME/theos

# Устанавливаем переменную окружения
echo 'export THEOS=$HOME/theos' >> ~/.zshrc
echo 'export PATH=$THEOS/bin:$PATH' >> ~/.zshrc

# Перезагружаем профиль
source ~/.zshrc
```

## 2. Установка зависимостей

### Для macOS:
```bash
# Устанавливаем Xcode Command Line Tools
xcode-select --install

# Устанавливаем Homebrew (если не установлен)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Устанавливаем необходимые пакеты
brew install ldid xz
```

### Для Linux:
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install build-essential git curl libssl-dev libusb-1.0-0-dev libplist-dev libzip-dev

# Устанавливаем ldid
curl -O http://joedj.net/ldid
chmod +x ldid
sudo mv ldid /usr/local/bin/
```

## 3. Настройка SDK

```bash
# Создаем директорию для SDK
mkdir -p $THEOS/sdks

# Скачиваем iOS SDK (замените версию на актуальную)
cd $THEOS/sdks
curl -L -O https://github.com/theos/sdks/archive/master.zip
unzip master.zip
mv sdks-master/* .
rm -rf sdks-master master.zip
```

## 4. Проверка установки

```bash
# Проверяем, что Theos работает
$THEOS/bin/nic.pl
```

## 5. Сборка проекта

После установки Theos:

```bash
cd /Users/igor/Documents/Velda/solo/MaxDestroyer
make clean
make package
```

Готовый .deb пакет будет находиться в папке `packages/`.

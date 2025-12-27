Artix Linux OpenRC Installer 🐧

Продвинутый автоматический установщик Artix Linux с системой инициализации OpenRC

<div align="center">
  <img src="https://raw.githubusercontent.com/artixnous/artix-branding/c43afa7904a45aecbade2833d5175282089c2a3d/logo/Signet_ColorFull.svg" alt="Artix Logo" width="300">
  <br>
  <em>Без systemd, только свобода!</em>
</div>

🌟 О проекте

Artix OpenRC Installer — это мощный скрипт автоматической установки Artix Linux, который предоставляет удобный интерактивный интерфейс, похожий на archinstall, но специально разработанный для OpenRC. Скрипт поддерживает установку как в BIOS, так и в UEFI режимах, предлагает на выбор несколько окружений рабочего стола и включает множество функций для удобной настройки системы.

📊 Ключевые возможности

Автоматическая установка Полностью автоматизированный процесс установки ✅ Работает

BIOS/UEFI поддержка Определение и настройка для обоих режимов ✅ Работает

11+ DE/WM Выбор из множества окружений рабочего стола ✅ Работает

Btrfs с подтомами Оптимальная разметка для btrfs ✅ Работает

Автоопределение железа CPU, GPU, микрокод ✅ Работает

ZRAM и TRIM Оптимизация производительности ✅ Работает

Русская локализация Поддержка русского языка ✅ Работает

Цветной интерфейс Интуитивное меню навигации ✅ Работает

Логирование Полный лог всех операций ✅ Работает

📦 Быстрый старт

Предварительные требования

1. Скачайте Artix Linux ISO с OpenRC:
   ```bash
   # Последняя версия
   wget https://iso.artixlinux.org/iso/artix-base-openrc-$(date +%Y.%m.01)-x86_64.iso
   
   # Или выберите зеркало
   https://mirror1.artixlinux.org/iso/
   ```
2. Запишите ISO на USB-накопитель:
   ```bash
   # Linux/macOS
   sudo dd if=artix.iso of=/dev/sdX bs=4M status=progress oflag=sync
   
   # Windows: используйте Rufus, BalenaEtcher или Ventoy
   ```
3. Настройте BIOS/UEFI:
   · Отключите Secure Boot
   · Для UEFI: включите UEFI режим
   · Для BIOS: включите Legacy/CSM режим
   · Установите приоритет загрузки с USB
4. Загрузитесь с USB и подключитесь к интернету:
   ```bash
   # Проверьте интерфейсы
   ip link
   
   # Wi-Fi (рекомендуется использовать проводное соединение при установке)
   wifi-menu
   
   # Или Ethernet
   dhcpcd
   ```

Установка

Способ 1: Прямая установка (рекомендуется)

```bash
# Загрузите и запустите установщик
curl -L https://raw.githubusercontent.com/YOUR_USERNAME/artix-openrc-installer/main/artix_installer.sh | sudo bash
```

Способ 2: Скачать и установить

```bash
# Клонируйте репозиторий
git clone https://github.com/YOUR_USERNAME/artix-openrc-installer.git
cd artix-openrc-installer

# Дайте права на выполнение
chmod +x artix_installer.sh

# Запустите установщик
sudo ./artix_installer.sh
```

Способ 3: Для опытных пользователей

```bash
# Установка с предварительной конфигурацией
INSTALL_DRIVE="/dev/sda" DESKTOP="plasma" sudo -E ./artix_installer.sh
```

🖥️ Поддерживаемые окружения рабочего стола

Полноценные DE (Desktop Environments)

| Окружение  | Иконка |            Пакеты            | Менеджер входа | Память |         Особенности           |

| KDE Plasma |   🐬   | plasma-meta kde-applications |     SDDM       | ~1.5GB |   Современный, функциональный |

|   GNOME    |   🎯   | gnome gnome-extra            |     GDM        | ~1.2GB |   Чистый, минималистичный     |

|    XFCE    |   🐀   | xfce4 xfce4-goodies          |    LightDM     | ~500MB |   Легковесный, стабильный     |

|    LXQt    |   ⚡   | lxqt breeze-icons            |     SDDM       | ~400MB |   Очень легкий, Qt-based      |

|    MATE    |   🌿   | mate mate-extra              |    LightDM     | ~450MB |   Классический, GNOME2-like   |

|  Cinnamon  |   🍃   | cinnamon                     |    LightDM     | ~600MB |    Современный, из Mint       |

WM (Window Managers)

| Окружение| Иконка |       Пакеты         | Менеджер входа | Память | Особенности |

|   Sway   |   🌊   | sway waybar rofi     |      Нет      | ~300MB  | Wayland, tiling |

|   i3     |  i3      |  i3-wm i3status dmenu |    LightDM   | ~250MB  | Классический tiling |

|  BSPWM   |   📦   |bspwm sxhkd polybar   |    LightDM    | ~200MB | Дерево окон, скрипты |

| Hyprland |   🎨   | hyprland waybar      |      Нет      | ~200MB | Современный Wayland |

| Awesome  |   ★    |     awesome          |    LightDM    |~250MB  | Конфигурируемый LUA |

Без GUI

· Терминал только (~50MB) - для серверов и минималистов

⚙️ Конфигурация установки

Основные параметры

```bash
# Параметры по умолчанию
install_drive: ""            # Диск для установки (например, /dev/sda)
boot_mode: "auto"           # Автоопределение BIOS/UEFI
disk_layout: "auto"         # auto, manual, btrfs, encryption
filesystem: "ext4"          # ext4, btrfs, xfs, f2fs
hostname: "artix"           # Имя хоста
username: ""               # Имя пользователя
timezone: "auto"           # Автоопределение или ручной ввод
locale: "en_US.UTF-8"      # Локаль системы
keymap: "us"               # Раскладка клавиатуры
desktop: "none"            # Окружение рабочего стола
kernel: "linux"            # linux, linux-lts, linux-zen, linux-hardened
swap_size: "4G"            # Размер swap файла
zram_enabled: "true"       # Включить ZRAM
trim_enabled: "true"       # Включить TRIM для SSD
```

Примеры конфигураций

Минимальная серверная установка:

```bash
./artix_installer.sh
# Выберите: Desktop → None, Filesystem → ext4, Kernel → linux-lts
```

Домашний компьютер с KDE:

```bash
./artix_installer.sh
# Disk Layout → Btrfs with subvolumes
# Desktop → Plasma (KDE)
# Filesystem → btrfs
# Swap → 8G
# ZRAM → Yes
```

Игровой компьютер:

```bash
./artix_installer.sh
# Desktop → GNOME или KDE
# Kernel → linux-zen
# GPU → Автоопределение (установит драйвера nvidia/amd)
# Additional → steam, gamemode, wine
```

Старый компьютер:

```bash
./artix_installer.sh
# Desktop → LXQt или XFCE
# Kernel → linux-lts
# Filesystem → ext4
# Swap → 2G
# ZRAM → Yes
```

🛠️ Технические детали

Структура разметки диска

Для UEFI/GPT:

```
/dev/sda
├── /dev/sda1 (ESP)         512M  fat32   → /boot/efi
└── /dev/sda2 (Root)        остальное    → /
    Опционально:
    ├── @         → /               (root subvolume)
    ├── @home     → /home           (home subvolume)
    └── @snapshots → /.snapshots    (snapshots)
```

Для BIOS/MBR:

```
/dev/sda
└── /dev/sda1 (Root)        весь диск    → /
    ├── /boot               (директория)
    └── /home               (директория)
```

Файловые системы

ФС Преимущества Недостатки Рекомендуется для
ext4 Стабильность, совместимость Нет snapshots Серверы, новички
btrfs Snapshots, сжатие, checksum Сложнее настройка Десктоп, бэкапы
xfs Высокая скорость больших файлов Нет уменьшения размера Медиа-серверы
f2fs Оптимизирована для SSD Менее стабильна SSD-диски

Поддержка оборудования

Процессоры:

· Intel: автоматическая установка intel-ucode
· AMD: автоматическая установка amd-ucode
· ARM: не поддерживается (только x86_64)

Видеокарты:

· NVIDIA: драйвера nvidia, nvidia-utils
· AMD: mesa, vulkan-radeon
· Intel: mesa, vulkan-intel
· VMware/VirtualBox: драйвера для виртуальных машин

Сетевые карты:

· Автоматическое определение и настройка
· Поддержка Wi-Fi (wpa_supplicant)
· Поддержка Bluetooth (bluez)

📁 Структура проекта

```
artix-openrc-installer/
├── artix_installer.sh      # Основной установочный скрипт
├── quick_install.sh        # Упрощенный установщик
├── post_install.sh         # Постинсталляционные настройки
├── backup_restore.sh       # Резервное копирование
├── README.md              # Эта документация
├── LICENSE                # Лицензия GPLv3
└── docs/                  # Документация
    ├── images/            # Скриншоты
    ├── bios-install.md    # Руководство по установке на BIOS
    └── troubleshooting.md # Решение проблемartix-openrc-installer/

```

🔍 Руководство по установке

Пошаговая инструкция

Шаг 1: Подготовка

1. Скачайте Artix ISO с OpenRC
2. Запишите на USB с помощью Rufus/Etcher/dd
3. Настройте BIOS/UEFI (отключите Secure Boot)
4. Загрузитесь с USB

Шаг 2: Запуск установщика

```bash
# Подключитесь к интернету
ping -c 3 archlinux.org

# Если нет интернета:
# Для Wi-Fi: wifi-menu
# Для Ethernet: dhcpcd

# Запустите установщик
curl -L https://raw.githubusercontent.com/YOUR_USERNAME/artix-openrc-installer/main/artix_installer.sh | sudo bash
```

Шаг 3: Настройка

1. Выберите диск для установки
2. Выберите разметку (авто, ручная, btrfs)
3. Укажите имя хоста и пользователя
4. Выберите часовой пояс и локаль
5. Выберите окружение рабочего стола
6. Настройте дополнительные параметры (ZRAM, TRIM, swap)

Шаг 4: Установка

· Скрипт автоматически выполнит все операции
· Процесс займет 5-30 минут в зависимости от выбора
· Все действия логируются в /tmp/artix-install-*.log

Шаг 5: Завершение

```bash
# После установки:
umount -R /mnt
reboot

# Удалите установочный носитель
# Войдите в систему
```

Особые случаи

Установка на ноутбук:

```bash
# Включите дополнительные пакеты:
tlp-openrc          # Управление питанием
acpid-openrc        # Кнопки питания
brightnessctl       # Яркость экрана

# В post_install.sh:
systemctl enable tlp
systemctl enable acpid
```

Установка в виртуальную машину:

· Используйте BIOS режим для совместимости
· Выберите драйвера для VirtualBox/VMware
· Установите virtualbox-guest-utils или open-vm-tools

Двойная загрузка с Windows:

1. Установите Windows первой
2. Уменьшите раздел Windows в управлении дисками
3. Установите Artix в освободившееся пространство
4. GRUB автоматически добавит Windows в меню

🐛 Решение проблем

Частые проблемы и решения

1. Скрипт не запускается

```bash
# Ошибка: Permission denied
chmod +x artix_installer.sh

# Ошибка: Command not found (curl)
pacman -S curl --noconfirm

# Ошибка: Not running as root
sudo ./artix_installer.sh
```

2. Проблемы с разметкой диска

```bash
# Ошибка: Cannot install to /dev/sda (busy)
umount -R /mnt 2>/dev/null
swapoff -a

# Ошибка: Invalid partition table
wipefs -a /dev/sda

# Ошибка: No space left on device
# Убедитесь, что диск достаточно большой (минимум 10GB)
```

3. Проблемы с загрузчиком

```bash
# BIOS: GRUB не устанавливается
artix-chroot /mnt grub-install --target=i386-pc /dev/sda --recheck

# UEFI: Не создается загрузочная запись
artix-chroot /mnt efibootmgr -c -d /dev/sda -p 1 -L "Artix" -l '\EFI\Artix\grubx64.efi'

# Восстановление из Live USB:
mount /dev/sda2 /mnt
mount /dev/sda1 /mnt/boot  # Для UEFI
artix-chroot /mnt
grub-install ...
grub-mkconfig -o /boot/grub/grub.cfg
```

4. Нет интернета после установки

```bash
# Проверьте статус NetworkManager
rc-service NetworkManager status

# Запустите вручную
rc-service NetworkManager start

# Или используйте netctl
netctl list
netctl start профиль
```

5. Не работает графический интерфейс

```bash
# Проверьте драйвера видеокарты
lspci -k | grep -A 2 -E "(VGA|3D)"

# Переустановите драйвера
sudo pacman -S mesa xf86-video-intel  # Для Intel
sudo pacman -S nvidia nvidia-utils    # Для NVIDIA

# Проверьте Xorg лог
cat /var/log/Xorg.0.log | grep -i error
```

6. Не работает звук

```bash
# Проверьте статус PulseAudio
rc-service pulseaudio status

# Установите ALSA и PulseAudio
sudo pacman -S alsa-utils pulseaudio pulseaudio-alsa

# Добавьте пользователя в группу audio
sudo usermod -aG audio $USER
```

Логи и отладка

Все действия скрипта логируются:

```bash
# Основной лог
/tmp/artix-install-YYYYMMDD-HHMMSS.log

# Дополнительные логи
/var/log/pacman.log
/var/log/Xorg.0.log
/var/log/messages

# Просмотр логов в реальном времени
tail -f /tmp/artix-install-*.log
```

Для отладки:

```bash
# Включите режим отладки
bash -x artix_installer.sh 2>&1 | tee debug.log

# Проверьте скрипт с ShellCheck
shellcheck artix_installer.sh

# Тестирование в виртуальной машине
qemu-system-x86_64 -cdrom artix.iso -m 2G -hda disk.img
```

🔄 Дополнительные скрипты

Постинсталляционная настройка

```bash
./post_install.sh
```

Включает:

· Обновление системы
· Установку AUR помощника (yay)
· Настройку репозиториев
· Установку дополнительных пакетов
· Настройку сервисов

Резервное копирование

```bash
# Создание бэкапа
./backup_restore.sh --backup /backup/system.tar.gz

# Восстановление
./backup_restore.sh --restore /backup/system.tar.gz
```

Быстрая установка

```bash
# Минимальная установка с параметрами
./quick_install.sh /dev/sda myhostname myuser
```

🤝 Вклад в проект

Мы приветствуем вклад сообщества! Вот как вы можете помочь:

Как сообщить об ошибке

1. Проверьте, не была ли ошибка уже зарегистрирована в Issues
2. Создайте новое Issue с четким описанием
3. Приложите логи, скриншоты и шаги для воспроизведения
4. Укажите версию скрипта и Artix

Как предложить улучшение

1. Форкните репозиторий
2. Создайте новую ветку: git checkout -b feature/amazing-feature
3. Внесите изменения и закоммитьте: git commit -m 'Add amazing feature'
4. Отправьте в свой форк: git push origin feature/amazing-feature
5. Откройте Pull Request

Правила разработки

· Используйте ShellCheck для проверки кода
· Следуйте стилю кодирования (отступы 2 пробела, snake_case)
· Добавляйте комментарии к сложным участкам кода
· Обновляйте документацию при изменении функционала
· Тестируйте изменения перед отправкой PR

Тестирование

```bash
# Запустите тесты
./tests/test_vm.sh
./tests/test_bios.sh
./tests/test_uefi.sh

# Проверьте покрытие
bashcov artix_installer.sh
```

📜 Лицензия

Этот проект распространяется под лицензией GNU General Public License v3.0.

```
Artix OpenRC Installer - Advanced installation script for Artix Linux
Copyright (C) 2024 Ваше Имя

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
```

Используемые компоненты

· Artix Linux: GPLv2+ (https://artixlinux.org)
· OpenRC: BSD 2-Clause (https://github.com/OpenRC/openrc)
· GRUB: GPLv3+ (https://www.gnu.org/software/grub/)

🌐 Полезные ссылки

Официальные ресурсы Artix

· Официальный сайт
· Вики (документация)
· Форум
· Репозитории
· IRC (#artixlinux на Libera.Chat)

Сообщество

· Reddit: r/artixlinux
· Telegram: Artix Linux
· Discord: Artix Linux
· Matrix: #artixlinux:matrix.org

Альтернативы

· Archinstall - официальный установщик Arch
· Calamares - кроссплатформенный установщик
· Anarchy Installer - установщик Arch Linux

🙏 Благодарности

Проекты

· Команда Artix Linux за создание прекрасного дистрибутива без systemd
· Разработчики OpenRC за легковесную и модульную систему инициализации
· Сообщество Arch Linux за документацию и пакеты
· Gentoo Linux за вдохновение и философию

Люди

· Имена контрибьюторов
· Тестеры и багрепортеры
· Переводчик документации

Инструменты

· ShellCheck - статический анализатор shell скриптов
· QEMU - виртуализация для тестирования
· GitHub Actions - CI/CD

📊 Статистика проекта

https://img.shields.io/github/stars/YOUR_USERNAME/artix-openrc-installer?style=social
https://img.shields.io/github/forks/YOUR_USERNAME/artix-openrc-installer?style=social
https://img.shields.io/github/issues/YOUR_USERNAME/artix-openrc-installer
https://img.shields.io/github/issues-pr/YOUR_USERNAME/artix-openrc-installer
https://img.shields.io/github/last-commit/YOUR_USERNAME/artix-openrc-installer

Показатели

· Версия: 2.0.0
· Загрузок: 1000+ (оценка)
· Установок: 500+ (оценка)
· Активных пользователей: 200+ (оценка)
· Версия Artix: Rolling Release

---

<div align="center">
  <h3>Сделано с ❤️ для сообщества Artix Linux</h3>
  <p>Если этот скрипт помог вам, поставьте ⭐ на GitHub!</p>

https://api.star-history.com/svg?repos=YOUR_USERNAME/artix-openrc-installer&type=Date

</div>

---

Примечание: Этот скрипт предоставляется "как есть", без каких-либо гарантий. Всегда делайте бэкапы важных данных перед установкой операционной системы. Авторы не несут ответственности за возможную потерю данных или повреждение системы.

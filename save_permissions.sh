#!/bin/bash

# İzinleri kaydetmek için dosya oluştur
echo "Dosya İzinleri Kaydı - $(date)" > permissions.txt

# Tüm dosyaların izinlerini recursive olarak kaydet
find . -type f -exec ls -l {} \; >> permissions.txt
find . -type d -exec ls -ld {} \; >> permissions.txt

echo "İzinler permissions.txt dosyasına kaydedildi." 
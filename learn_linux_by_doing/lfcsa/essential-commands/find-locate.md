
# Find/Locate/Which/Where/Typeis
Search for Files and Directories!
## Find - Usage/Examples

* Finding a file in current directory with specific name.
```
find -name test.txt
```
* Finding specific file in a specific directory.
```
find /etc -name test.txt
```
* Finding incase sensitive files in a specific directory.
```
find /etc -iname test.txt
```
* Finding multiple files in a specific file extention.
```
find /etc -type f -name *.log

-type:
c - input devices
d - directory
f - file
l - links
```
* Finding files owned by a specific user.
```
find / -type f -user sam
```
## Locate - Usage/Examples (Keep your db updated: sudo updatedb)
* Locate the specific files. 
```
locate test.txt
```
* Locate multiple incase-sensitive files.
```
locate -i test.txt
```
## Which - Usage/Examples
* To search where the package is installed.
```
which python
which nano
which vim
```
## Whereis - Usage/Examples
* To search where the package is installed.
```
whereis python
whereis nano
whereis vim
```
## Type - Usage/Examples
* To search where the package is installed.
```
type python
type nano
type vim
```
## Feedback
If you have any feedback, please reach out to us at hello@tamilvanan.live 📧
## Authors

- [@Tamilvanan Gowran 😎](https://www.github.com/gtamilvanan17)


## License

[MIT](https://choosealicense.com/licenses/mit/)


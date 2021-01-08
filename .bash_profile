crtsh(){
curl -s https://crt.sh/?Identity=%.$1 | grep ">*.$1" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$1" | sort -u | awk 'NF'
}

certspotter(){ 
curl -s https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1
}

# Input: domain name
subs_passive(){
if [ -z "$CENSYS_API_ID" ]; then echo "Please export API ID and Secret" && exit 1; fi 
python /root/tools/censys-subdomain-finder/censys_subdomain_finder.py $1 -o censys_output_tmp.txt 
crtsh $1 > crtsh_output_tmp.txt 
subfinder -d $1 -o subfinder_output_tmp.txt 
python /root/tools/Sublist3r/sublist3r.py -d $1 -o sublister_output_tmp.txt 
cat *_output_tmp.txt | sort -u > subdomains_passive.txt 
rm *_output_tmp.txt
}

# Input: subdomains file
subs_validate(){
rm /root/tools/nameservers.txt
wget https://public-dns.info/nameservers.txt -O /root/tools/nameservers/nameservers.txt
massdns -r /root/tools/nameservers/nameservers.txt -o S -w massdns.txt $1 
awk -F ". " '{print $1}' "massdns.txt" | sort -u > subdomains_live.txt 
grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' massdns.txt | sort -u > ips_live.txt 
rm massdns.txt
}

# Input: live subdomains
aqua(){
cat $1 | aquatone -out aquatone
}

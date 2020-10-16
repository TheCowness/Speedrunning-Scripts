--LUA script for pulling data from the DW4 rom

--"Map" tying memory values to letters/words in DW4
map = {'A ','B ','C ','D ','E ','F ','G ','H ','I ','J ','K ','L ','M ','N ','O ','P ','Q ','R ','S ','T ','U ','V ','W ','X ','Y ','Z ','  ','- ',"' ",'  ',': ','  ','  ','  ','er','on','an','or','ar','le','ro','al','re','st','in','ba','ra','ma',' s','he','ea','en','th','el','n ','te','et','e ','mo','of','ng','at','de','f ','rd','ta','ag','me',' o','ir','ha','la','ni','ce','hi','ic','ll','li','sa','nt','do','ia','no','to','ur','es','ou','pe','rm','as','il','ri',' h',' m','s ','ab','be','ee','em','go','it','l ','ve','dr','ie','ne','r ','wo','ad','ch','ed','nd','se','sh','tr',' a','bl','fe','ld','nc','ol','os','rn','si','vi',' b',' d','am','ge','ig','mi','ot','ti','us',' c','g ','is','lo','od','sw','za','ze',' r','ac','cl','co','d ','gh','ho','io','ke','oo','op','so','un','y ','ai','bi','cr','da','id','im','om','pi','po','af','ck','ff','gi','gu','ht','iv','rr','sp','ss','t ','ap','bo','ec','fu','na','sl',' p',' w',"'s",'ak','di','fi','f ','iz','ki','lu','mp','nf','rc','av','bb','ca','ef','eo','fa','fl','ga','gr','ly','mb','nu','og','ow','pa','pl','pp','ry','sk','tt','tu','wi',' k',' n',' t','ay','az','a ','br','ds','fo','kn','k ','lm','ns','oa','ob','oi','ph','ty','ul','um','ut','wa','au','ct','c ','d ','eb','ep','ev','ey','e ','ip','ka','ko','nb','pr','rt','sc','ua','  '}

function DEC_HEX(IN,final_digits)
    Base = 16;
	Values = "0123456789ABCDEF";
	OUT = "";
	Digit = 0;
	I = 0;
	digits = 0;
    while IN>0 do
        I=I+1;
		Digit=math.mod(IN,Base)+1;
        IN=math.floor(IN/Base);
        OUT=string.sub(Values,Digit,Digit)..OUT;
		digits = digits + 1;
    end;
	while digits < final_digits do
		OUT = '0'..OUT;
		digits = digits + 1;
	end;
    return OUT;
end;



--Let's dump the entire rom, using these words.
i = 0
j = rom.readbyte(i)
outfile = io.open("Dragon Warrior IV Text Dump.txt","a")
io.output(outfile)
while j do
	if i % 0x40 == 0 then
		io.write('\n'..DEC_HEX(i,6)..': ')
		emu.frameadvance();
		gui.text(10,10,"i: "..DEC_HEX(i,6))
	end
	io.write(map[j+1])
	i = i + 1
	j = rom.readbyte(i)
end
io.close(outfile)
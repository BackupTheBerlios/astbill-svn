<?php
// require('modules/astprof/invoice/fpdf.php');
// require_once(dirname(__FILE__) . DIRECTORY_SEPARATOR . '../fpdf' . DIRECTORY_SEPARATOR . 'fpdf.php');
require_once(dirname(__FILE__) . DIRECTORY_SEPARATOR . 'fpdf' . DIRECTORY_SEPARATOR . 'fpdf.php');

/*
 * AstBill  -- Billing, Routing and Management software for Asterisk and MySQL using Drupal
 *
 * www.astbill.com
 *
 * Asterisk -- A telephony toolkit for Linux.
 * Drupal   -- An Open source content management platform.
 *
 * 
 * Copyright (C) 2005, AOFFICE NOMINEE SECRETARIES LIMITED, UNITED KINGDOM.
 *
 * Andreas Mikkelborg <adoroar [Guess What?] astartelecom.com>
 * Are Casilla        <areast  [Guess What?] astartelecom.com>
 *
 *
 * This program is free software, distributed under the terms of
 * the GNU General Public License
 *
 * 2007.13.13 Version 0.9.20 Are Casilla
 * 
 */


class PDFLIST extends FPDF
{
var $ProcessingTable=false;
var $aCols=array();
var $TableX;
var $HeaderColor;
var $RowColors;
var $ColorIndex;

var $Journalno;
var $Invoiceid;


function TableHeader()
{
    $this->SetFont('Arial','B',10);
    $this->SetX($this->TableX);
    $fill=!empty($this->HeaderColor);
    if($fill)
        $this->SetFillColor($this->HeaderColor[0],$this->HeaderColor[1],$this->HeaderColor[2]);
    foreach($this->aCols as $col)
        $this->Cell($col['w'],6,$col['c'],1,0,'C',$fill);
    $this->Ln();
}

function TableFooter()
{
/*  $this->SetFont('Arial','B',11);
    $this->SetX($this->TableX);
    $fill=!empty($this->HeaderColor);
    if($fill)
        $this->SetFillColor($this->HeaderColor[0],$this->HeaderColor[1],$this->HeaderColor[2]);
    foreach($this->aCols as $col)
        // $this->Cell($col['w'],6,$col['c'],1,0,'C',$fill);
        $this->Cell($col['w'],6,"dsfsadfdsf",1,0,'C',$fill);
    $this->Ln();
*/
}

function Row($data)
{
    $this->SetX($this->TableX);
    $ci=$this->ColorIndex;
    $fill=!empty($this->RowColors[$ci]);
    if($fill)
        $this->SetFillColor($this->RowColors[$ci][0],$this->RowColors[$ci][1],$this->RowColors[$ci][2]);
    foreach($this->aCols as $col)
		{
			$rowtext = utf82uni($data[$col['f']]);  // Convert Norwegian letters
			$this->Cell($col['w'],5,$rowtext,1,0,$col['a'],$fill);
		}
    $this->Ln();
    $this->ColorIndex=1-$ci;
}

function CalcWidths($width,$align)
{
    //Compute the widths of the columns
    $TableWidth=0;
    foreach($this->aCols as $i=>$col)
    {
        $w=$col['w'];
        if($w==-1)
            $w=$width/count($this->aCols);
        elseif(substr($w,-1)=='%')
            $w=$w/100*$width;
        $this->aCols[$i]['w']=$w;
        $TableWidth+=$w;
    }
    //Compute the abscissa of the table
    if($align=='C')
        $this->TableX=max(($this->w-$TableWidth)/2,0);
    elseif($align=='R')
        $this->TableX=max($this->w-$this->rMargin-$TableWidth,0);
    else
        $this->TableX=$this->lMargin;
}

function AddCol($field=-1,$width=-1,$caption='',$align='L')
{
    //Add a column to the table
    if($field==-1)
        $field=count($this->aCols);
    $this->aCols[]=array('f'=>$field,'c'=>$caption,'w'=>$width,'a'=>$align);
}

function Table($query,$prop=array())
{
    //Issue query
    $res=mysql_query($query) or die('Error: '.mysql_error()."<BR>Query: $query");
    //Add all columns if none was specified
    if(count($this->aCols)==0)
    {
        $nb=mysql_num_fields($res);
        for($i=0;$i<$nb;$i++)
            $this->AddCol();
    }
    //Retrieve column names when not specified
    foreach($this->aCols as $i=>$col)
    {
        if($col['c']=='')
        {
            if(is_string($col['f']))
                $this->aCols[$i]['c']=ucfirst($col['f']);
            else
                $this->aCols[$i]['c']=ucfirst(mysql_field_name($res,$col['f']));
        }
    }
    //Handle properties
    if(!isset($prop['width']))
        $prop['width']=0;
    if($prop['width']==0)
        $prop['width']=$this->w-$this->lMargin-$this->rMargin;
    if(!isset($prop['align']))
        $prop['align']='C';
    if(!isset($prop['padding']))
        $prop['padding']=$this->cMargin;
    $cMargin=$this->cMargin;
    $this->cMargin=$prop['padding'];
    if(!isset($prop['HeaderColor']))
        $prop['HeaderColor']=array();
    $this->HeaderColor=$prop['HeaderColor'];
    if(!isset($prop['color1']))
        $prop['color1']=array();
    if(!isset($prop['color2']))
        $prop['color2']=array();
    $this->RowColors=array($prop['color1'],$prop['color2']);
    //Compute column widths
    $this->CalcWidths($prop['width'],$prop['align']);
    //Print header
    $this->TableHeader();
    //Print rows
    $this->SetFont('Arial','',10);
    $this->ColorIndex=0;
    $this->ProcessingTable=true;
    while($row=mysql_fetch_array($res))
        $this->Row($row);
    $this->ProcessingTable=false;
    //Print Footer
	$this->TableFooter();
	$this->cMargin=$cMargin;
    $this->aCols=array();

}
//Page header
function Header() {
	global $db_prefix;

	if ($db_prefix == 'ip2p_') {
		$this->SetFont('Arial','B',12);
  	    $this->SetXY(10,2);
		$companyinfo = "Ippcom AS\n";
		$this->Cell(0,10,$companyinfo,0,0,'L');
		$this->SetXY(10,9);
		$companyinfo = "Postbox 115\n1325 Lysaker";
		$this->SetFont('Arial','',10);
		 $this->WriteText($companyinfo);

//		$this->Image('modules/astprof/invoice/ippcom_pdf50.jpg', 10, 0);
//		// $this->Image('modules/astprof/invoice/ippcom60.jpg', 10, 0);
//		$companyinfo = "\nIppcom AS\nPostbox 115\n1325 Lysaker";
//		$companyinfo2 = "\nOrg.nr. : NO986103031MVA\nTelefon: +47 815 10 215\nTelefax: +47 815 10 216";
//		$companyinfo3 = "\nEpost: support@ippcom.no\nWeb: www.ippcom.no";
//		$clientaddress = utf82uni($company."".$ret->inv_firstname." ".$ret->inv_lastname."\n".$address."\n".$ret->inv_zip." ".$ret->inv_city);
//		$invoiceinfo = "Fakturanummer:\nKundenummer:\nFakturadato:\nForfallsdato:\nKID:";
//		$invoicevalue = $ret->invoiceno."\n".$ret->uid."\n".$ret->invoice_date."\n".$ret->due_date."\n".$ret->kid;
		// $footertexttitle = "Vær oppmerksom på følgende:";
		$footertexttitle = "";
		$footertext = "";
	} else {
		// $this->Image('modules/astprof/invoice/cbktele.png', 10, 0, 44);
		// $this->Image('modules/astprof/invoice/cbktele.png', 10, 0, 33);
		$this->SetFont('Arial','B',12);
  	    $this->SetXY(10,2);
		$companyinfo = "AstBill\n";
		$this->Cell(0,10,$companyinfo,0,0,'L');

//		$this->SetXY(-15,2);
//		$text = "Fakturajournal";
//		$this->Cell(0,10,$text,0,0,'R');

		$this->SetXY(10,9);
		$companyinfo = "Billing Street 20\nLondon SW1 5BB";

		$this->SetFont('Arial','',10);
		// $this->Cell(0,10,$companyinfo,0,0,'L');
		// $this->Cell(0,10,$companyinfo,0,0,'L');
		 $this->WriteText($companyinfo);

	if (arg(1)=="astpdfpricelist"){
 		$this->SetXY(20,10);
		$this->SetFont("Arial",'b',10);
   		$this->Cell(185,5,'International Price List',0,0,"C");

		$this->SetXY(20,20);
		$this->SetFont("Arial",'b',8);
		$this->SetFillColor(200,200,200);
		$this->Cell(75,5,"International Destinations",1,0,"C",1);
		$this->Cell(40,5,"Countrycode",1,0,"C",1);
		$this->Cell(55,5,"Minute price",1,0,"C",1);
		//$this->Ln();
	}

/*
		 $this->SetFont('Arial','B',10);
		 $this->SetXY(-15,11);
		 $text = "Journalnummer: 1";
		 $this->Cell(0,10,$text,0,0,'R');
		 $this->SetFont('Arial','',10);
		 $this->SetXY(10,20);
		 $this->Cell(0,10,"",0,0,'L');
*/
	}

 $this->Ln();
//Fields Name position
 $Y_Fields_Name_position = 20;
//Table position, under Fields Name
$Y_Table_Position = 26;

/*
//First create each Field Name
//Gray color filling each Field Name box
//$this->SetFillColor(232,232,232);
$this->SetFillColor(240,240,240);
//Bold Font for Field Name
$this->SetFont('Arial','B',10);
// $this->Line($this->GetX(), $this->GetY(), $rightX, $this->GetY());
$this->SetY($Y_Fields_Name_position);
$this->SetX(45);
$this->Cell(20,6,'CODE',1,0,'L',1);
$this->SetX(65);
$this->Cell(100,6,'NAME',1,0,'L',1);
$this->SetX(135);
$this->Cell(30,6,'PRICE',1,0,'R',1);
$this->Ln();
*/
    //Print the table header if necessary
    if($this->ProcessingTable)
        $this->TableHeader();

}

//Page footer
function Footer() {
	global $user;
	static $timeprintet;
	$timeprintet = date('Y-m-d H-i-s');
	$oldX = $this->GetX();
	$this->SetX(-10);
	$rightX = $this->GetX();
	$this->SetX($oldX);
	//Position at 1.5 cm from bottom
    $this->SetY(-15);

	// $this->MultiCell(120,6,'',1);
	// Line(float x1, float y1, float x2, float y2)
	// $this->Line(10, 100, 300, 100);

	$this->Line($this->GetX(), $this->GetY(), $rightX, $this->GetY());

	//Arial italic 8
    $this->SetFont('Arial','I',8);
    //Page number
    $this->Cell(0,10,t('Page').' '.$this->PageNo().'/{nb}',0,0,'C');
	$this->SetX(10);
    $this->Cell(0,10,t('Printed by').': '.$user->name,0,0,'L');
	$this->SetX(-10-$this->GetStringWidth($timeprintet));
    $this->Cell(0,10,$timeprintet,0,0,'L');
//	$this->WriteText("Printet av Are");
//	$this->WriteText("jks dfkjasdh fjksdahf kjashdf kjasfhd kjasfhd kajsfhd ");
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WriteText($text)
{
    $text = utf82uni($text);
	$intPosIni = 0;
    $intPosFim = 0;
    if (strpos($text,'<')!==false and strpos($text,'[')!==false)
    {
        if (strpos($text,'<')<strpos($text,'['))
        {
            $this->Write(5,substr($text,0,strpos($text,'<')));
            $intPosIni = strpos($text,'<');
            $intPosFim = strpos($text,'>');
            $this->SetFont('','B');
            $this->Write(5,substr($text,$intPosIni+1,$intPosFim-$intPosIni-1));
            $this->SetFont('','');
            $this->WriteText(substr($text,$intPosFim+1,strlen($text)));
        }
        else
        {
            $this->Write(5,substr($text,0,strpos($text,'[')));
            $intPosIni = strpos($text,'[');
            $intPosFim = strpos($text,']');
            $w=$this->GetStringWidth('a')*($intPosFim-$intPosIni-1);
            $this->Cell($w,$this->FontSize+0.75,substr($text,$intPosIni+1,$intPosFim-$intPosIni-1),1,0,'');
            $this->WriteText(substr($text,$intPosFim+1,strlen($text)));
        }
    }
    else
    {
        if (strpos($text,'<')!==false)
        {
            $this->Write(5,substr($text,0,strpos($text,'<')));
            $intPosIni = strpos($text,'<');
            $intPosFim = strpos($text,'>');
            $this->SetFont('','B');
            $this->WriteText(substr($text,$intPosIni+1,$intPosFim-$intPosIni-1));
            $this->SetFont('','');
            $this->WriteText(substr($text,$intPosFim+1,strlen($text)));
        }
        elseif (strpos($text,'[')!==false)
        {
            $this->Write(5,substr($text,0,strpos($text,'[')));
            $intPosIni = strpos($text,'[');
            $intPosFim = strpos($text,']');
            $w=$this->GetStringWidth('a')*($intPosFim-$intPosIni-1);
            $this->Cell($w,$this->FontSize+0.75,substr($text,$intPosIni+1,$intPosFim-$intPosIni-1),1,0,'');
            $this->WriteText(substr($text,$intPosFim+1,strlen($text)));
        }
        else
        {
            $this->Write(5,$text);
        }

    }
}

function OrderText($text1,$text2,$text3="",$text4="",$lf=TRUE) {
	// $pdf->SetFont('Arial','',12);
	$text1 = utf82uni($text1);
	$text2 = utf82uni($text2);
	$text3 = utf82uni($text3);
	$text4 = utf82uni($text4);

	$len = ($text3=="") ?  '145' : '50';
	$this->Cell(45,5,$text1.':',0,0,'L');
	$this->SetX(46);
	$this->Cell($len,5,$text2,1,0,'L');
	if ($text3 <> "") {
		$this->SetX(100);
		$this->Cell(40,5,$text3.':',0,0,'L');
		$this->SetX(141);
		$this->Cell(50,5,$text4,1,1,'L');
	} else { $this->WriteText("\n"); }
	if ($lf == TRUE) { $this->WriteText("\n"); }
}

// *****************************************************************************************************************

function WriteHTML($html)
    {
        //HTML parser
        $html=str_replace("\n",' ',$html);
        $a=preg_split('/<(.*)>/U',$html,-1,PREG_SPLIT_DELIM_CAPTURE);
        foreach($a as $i=>$e)
        {
            if($i%2==0)
            {
                //Text
                if($this->HREF)
                    $this->PutLink($this->HREF,$e);
                elseif($this->ALIGN == 'center')
                    $this->Cell(0,5,$e,0,1,'C');
                else
                    $this->Write(5,$e);
            }
            else
            {
                //Tag
                if($e{0}=='/')
                    $this->CloseTag(strtoupper(substr($e,1)));
                else
                {
                    //Extract properties
                    $a2=split(' ',$e);
                    $tag=strtoupper(array_shift($a2));
                    $prop=array();
                    foreach($a2 as $v)
                        if(ereg('^([^=]*)=["\']?([^"\']*)["\']?$',$v,$a3))
                            $prop[strtoupper($a3[1])]=$a3[2];
                    $this->OpenTag($tag,$prop);
                }
            }
        }
    }

    function OpenTag($tag,$prop)
    {
        //Opening tag
        if($tag=='B' or $tag=='I' or $tag=='U')
            $this->SetStyle($tag,true);
        if($tag=='A')
            $this->HREF=$prop['HREF'];
        if($tag=='BR')
            $this->Ln(5);
        if($tag=='P')
            $this->ALIGN=$prop['ALIGN'];
        if($tag=='HR')
        {
            if( $prop['WIDTH'] != '' )
                $Width = $prop['WIDTH'];
            else
                $Width = $this->w - $this->lMargin-$this->rMargin;
            $this->Ln(2);
            $x = $this->GetX();
            $y = $this->GetY();
            $this->SetLineWidth(0.4);
            $this->Line($x,$y,$x+$Width,$y);
            $this->SetLineWidth(0.2);
            $this->Ln(2);
        }
    }

    function CloseTag($tag)
    {
        //Closing tag
        if($tag=='B' or $tag=='I' or $tag=='U')
            $this->SetStyle($tag,false);
        if($tag=='A')
            $this->HREF='';
        if($tag=='P')
            $this->ALIGN='';
    }

    function SetStyle($tag,$enable)
    {
        //Modify style and select corresponding font
        $this->$tag+=($enable ? 1 : -1);
        $style='';
        foreach(array('B','I','U') as $s)
            if($this->$s>0)
                $style.=$s;
        $this->SetFont('',$style);
    }

    function PutLink($URL,$txt)
    {
        //Put a hyperlink
        $this->SetTextColor(0,0,255);
        $this->SetStyle('U',true);
        $this->Write(5,$txt,$URL);
        $this->SetStyle('U',false);
        $this->SetTextColor(0);
	}

} // End of class

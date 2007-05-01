<?php
require('modules/astprof/invoice/fpdf.php');
define('EURO', chr(128) );
define('EURO_VAL', 6.55957 );

// Xavier Nicolay 2004
// Version 1.01

//////////////////////////////////////
// Public functions                 //
//////////////////////////////////////
//  function sizeOfText( $texte, $larg )
//  function addSociete( $nom, $adresse )
//  function fact_dev( $libelle, $num )
//  function addDevis( $numdev )
//  function addFacture( $numfact )
//  function addDate( $date )
//  function addClient( $ref )
//  function addPageNumber( $page )
//  function addClientAdresse( $adresse )
//  function addReglement( $mode )
//  function addEcheance( $date )
//  function addNumTVA($tva)
//  function addReference($ref)
//  function addCols( $tab )
//  function addLineFormat( $tab )
//  function lineVert( $tab )
//  function addLine( $ligne, $tab )
//  function addRemarque($remarque)
//  function addCadreTVAs()
//  function addCadreEurosFrancs()
//  function addTVAs( $params, $tab_tva, $invoice )
//  function temporaire( $texte )

class INVOICE extends FPDF
{
// private variables
var $colonnes;
var $format;
var $angle=0;

// private functions
function RoundedRect($x, $y, $w, $h, $r, $style = '')
{
	$k = $this->k;
	$hp = $this->h;
	if($style=='F')
		$op='f';
	elseif($style=='FD' or $style=='DF')
		$op='B';
	else
		$op='S';
	$MyArc = 4/3 * (sqrt(2) - 1);
	$this->_out(sprintf('%.2f %.2f m',($x+$r)*$k,($hp-$y)*$k ));
	$xc = $x+$w-$r ;
	$yc = $y+$r;
	$this->_out(sprintf('%.2f %.2f l', $xc*$k,($hp-$y)*$k ));

	$this->_Arc($xc + $r*$MyArc, $yc - $r, $xc + $r, $yc - $r*$MyArc, $xc + $r, $yc);
	$xc = $x+$w-$r ;
	$yc = $y+$h-$r;
	$this->_out(sprintf('%.2f %.2f l',($x+$w)*$k,($hp-$yc)*$k));
	$this->_Arc($xc + $r, $yc + $r*$MyArc, $xc + $r*$MyArc, $yc + $r, $xc, $yc + $r);
	$xc = $x+$r ;
	$yc = $y+$h-$r;
	$this->_out(sprintf('%.2f %.2f l',$xc*$k,($hp-($y+$h))*$k));
	$this->_Arc($xc - $r*$MyArc, $yc + $r, $xc - $r, $yc + $r*$MyArc, $xc - $r, $yc);
	$xc = $x+$r ;
	$yc = $y+$r;
	$this->_out(sprintf('%.2f %.2f l',($x)*$k,($hp-$yc)*$k ));
	$this->_Arc($xc - $r, $yc - $r*$MyArc, $xc - $r*$MyArc, $yc - $r, $xc, $yc - $r);
	$this->_out($op);
}

function _Arc($x1, $y1, $x2, $y2, $x3, $y3)
{
	$h = $this->h;
	$this->_out(sprintf('%.2f %.2f %.2f %.2f %.2f %.2f c ', $x1*$this->k, ($h-$y1)*$this->k,
						$x2*$this->k, ($h-$y2)*$this->k, $x3*$this->k, ($h-$y3)*$this->k));
}

function Rotate($angle,$x=-1,$y=-1)
{
	if($x==-1)
		$x=$this->x;
	if($y==-1)
		$y=$this->y;
	if($this->angle!=0)
		$this->_out('Q');
	$this->angle=$angle;
	if($angle!=0)
	{
		$angle*=M_PI/180;
		$c=cos($angle);
		$s=sin($angle);
		$cx=$x*$this->k;
		$cy=($this->h-$y)*$this->k;
		$this->_out(sprintf('q %.5f %.5f %.5f %.5f %.2f %.2f cm 1 0 0 1 %.2f %.2f cm',$c,$s,-$s,$c,$cx,$cy,-$cx,-$cy));
	}
}

function _endpage()
{
	if($this->angle!=0)
	{
		$this->angle=0;
		$this->_out('Q');
	}
	parent::_endpage();
}

// public functions
function sizeOfText( $texte, $largeur )
{
	$index    = 0;
	$nb_lines = 0;
	$loop     = TRUE;
	while ( $loop )
	{
		$pos = strpos($texte, "\n");
		if (!$pos)
		{
			$loop  = FALSE;
			$ligne = $texte;
		}
		else
		{
			$ligne  = substr( $texte, $index, $pos);
			$texte = substr( $texte, $pos+1 );
		}
		$length = floor( $this->GetStringWidth( $ligne ) );
		$res = 1 + floor( $length / $largeur) ;
		$nb_lines += $res;
	}
	return $nb_lines;
}

// Company
function addSociete( $nom, $adresse )
{
	$x1 = 10;
	$y1 = 8;
	//Positionnement en bas
	$this->SetXY( $x1, $y1 );
	$this->SetFont('Arial','B',12);
	$length = $this->GetStringWidth( $nom );
	$this->Cell( $length, 2, $nom);
	$this->SetXY( $x1, $y1 + 4 );
	$this->SetFont('Arial','',8);
	$length = $this->GetStringWidth( $adresse );
	//Coordonnées de la société
	$lignes = $this->sizeOfText( $adresse, $length) ;
	$this->MultiCell($length, 4, $adresse);
}

function addSociete2( $nom, $adresse )
{
	$x1 = 40;
	$y1 = 8;
	//Positionnement en bas
	$this->SetXY( $x1, $y1 );
	$this->SetFont('Arial','B',12);
	$length = $this->GetStringWidth( $nom );
	$this->Cell( $length, 2, $nom);
	$this->SetXY( $x1, $y1 + 4 );
	$this->SetFont('Arial','',8);
	$length = $this->GetStringWidth( $adresse );
	//Coordonnées de la société
	$lignes = $this->sizeOfText( $adresse, $length) ;
	$this->MultiCell($length, 4, $adresse);
}

function addSociete3( $nom, $adresse )
{
	$x1 = 80;
	$y1 = 8;
	//Positionnement en bas
	$this->SetXY( $x1, $y1 );
	$this->SetFont('Arial','B',12);
	$length = $this->GetStringWidth( $nom );
	$this->Cell( $length, 2, $nom);
	$this->SetXY( $x1, $y1 + 4 );
	$this->SetFont('Arial','',8);
	$length = $this->GetStringWidth( $adresse );
	//Coordonnées de la société
	$lignes = $this->sizeOfText( $adresse, $length) ;
	$this->MultiCell($length, 4, $adresse);
}

function mod10($inv)
{   
     for ($x=0; $x<strlen($inv); $x++) {
     $digit = substr($inv, $x, 1);   
        	if (strlen($inv) % 2 == 1)
	{
		//to multiply by 2 and then by 1
		if ($x/2 == floor($x/2)) $digit *= 2;
		// end multiplicaton
        }
	else
        {
		//to multiple first by 1 and then by 2
		if ($x/2 == floor($x/2))
		$digit *= 1;
		else
		$digit *= 2;
        }
        //end multiplication

      if (strlen($digit) == 2) $digit = substr($digit, 0, 1) + substr($digit, 1, 1);
      $mysum += $digit;
    }        
    $rem = $mysum % 10;       
    //if remainder is string, just a way to convert to integer by adding 0
    $rem = $rem + 0;
    if ($rem == 0)
        {       
            $checkdigit = 0;
        }
        else
        {
         $checkdigit = 10 - $rem;
        }      
return $checkdigit;
}

function insertH($x1, $y1, $text)
{
	$this->SetXY( $x1-10, $y1+285 );
	$this->Cell(1,$y1-10, $text, 0, 0, "R", 0);	
}

function insertkid($x1, $y1, $text)
{
	$this->SetXY( $x1-10, $y1+285 );
	$this->Cell($x1,1, $text, 0, 0, "R", 0);	

//	$this->SetXY( $x1-10, $y1+285 );
//	$this->Cell($x1,$y1-10, $text, 0, 0, "R", 0);	
}

function insertdate($x1, $y1, $text)
{
	$this->SetXY( $x1+140, $y1+200 );
	$this->Cell($x1-20,$y1-10, $text, 0, 0, "R", 0);	
}

function insertsum($x1, $y1, $text)
{
	// TOP SIDE  yl=linjeno     xl=left margin
	$this->SetXY( $x1+50, $y1+203 );
	$this->Cell($x1-50,$y1-10, $text, 0, 0, "R", 0);
	
	// DOWN SIDE  yl=linjeno     xl=left margin
	$nr = strlen($text)-3;
	$bottomsump2 = substr($text, 0, $nr);
	$bottomsump1 = substr($text, -2);
	
	$this->SetXY( $x1+48, $y1+285 );
 	$this->Cell($x1-49,1, $bottomsump2.'  '.$bottomsump1, 0, 0, "R", 0);
}

function insertchecksum($x1, $y1, $text)
{
	$nr = strlen($text)-2;
	$bottomsump2 = substr($text, 0, $nr);
	$bottomsump1 = substr($text, -1);
	$checkthis = $bottomsump2.''.$bottomsump1.'0';
	$checksum = $this->mod10($checkthis);
	
	$this->SetXY( $x1-10, $y1+285 );
	$this->Cell($x1,1, $checksum, 0, 0, "R", 0);
}

function insertbankno($x1, $y1, $text)
{
	// TOP SIDE      yl=linjeno     xl=left margin
	$this->SetXY( $x1-77, $y1+196 );
	$this->Cell($x1-48,1, $text, 0, 0, "R", 0);
	
	// DOWN SIDE
	$this->SetXY( $x1+51, $y1+285 );
	$this->Cell($x1-50,1, $text, 0, 0, "R", 0);
	
}
function insertfooter($x1, $y1, $footertext)
{
//	$this->SetXY( $x1, $y1 );
//	$this->Cell(0,6, $text, 0, 0, "L", 0);

	$this->SetXY( $x1, $y1);
	$this->SetFont('Arial','',6);
	$length = $this->GetStringWidth( $footertext );
	$lignes = $this->sizeOfText( $footertext, $length) ;
	$this->MultiCell($length+2, 4, $footertext);
	$this->SetFont('Ocrb','',14);
}

function insertpayinfo($x1, $y1, $text)
{
	$x = 0;
	$r1 = 5;
	while (!empty($text[$x])) {
		
		$this->SetXY( $x1, $y1+$r1 );
		$this->Cell(10,1, $text[$x], 0, 0, "L", 0);
		
		$x++;
		$r1 += 4;
	}
}

function insertpayedby($x1, $y1, $text)
{
	$x = 0;
	$r1 = 5;
	while (!empty($text[$x])) {
		
		$this->SetXY( $x1, $y1+$r1 );
		$this->Cell(10,1, $text[$x], 0, 0, "L", 0);
		
		$x++;
		$r1 += 4;
	}
}

function insertpayedto($x1, $y1, $text)
{
	$x = 0;
	$r1 = 5;
	while (!empty($text[$x])) {
		
		$this->SetXY( $x1, $y1+$r1 );
		$this->Cell(10,1, $text[$x], 0, 0, "L", 0);
		
		$x++;
		$r1 += 4;
	}
}

function addfootertxt( $footertexttitle, $footertext )
{
	$x1 = 10;
	$y1 = -45;  // AstBill - Was -46
	$this->SetXY( $x1, $y1 );
	$this->SetFont('Arial','B',6);
	$length = $this->GetStringWidth( $footertexttitle );
	$this->Cell( $length, 2, $footertexttitle);
	
	$this->SetXY( $x1, $y1 + 4 );
	$this->SetFont('Arial','',6);
	$length = $this->GetStringWidth( $footertext );
	$lignes = $this->sizeOfText( $footertext, $length) ;
	$this->MultiCell($length+2, 4, $footertext);
}

// Label and number of invoice/estimate
function fact_dev( $libelle )
{
    $r1  = $this->w - 80;
    $r2  = $r1 + 68;
    $y1  = 6;
    $y2  = $y1 + 2;
    $mid = ($r1 + $r2 ) / 2;
    
    $texte  = $libelle;    
    $szfont = 12;
    $loop   = 0;
    
    while ( $loop == 0 )
    {
       $this->SetFont( "Helvetica", "B", $szfont );
       $sz = $this->GetStringWidth( $texte );
       if ( ($r1+$sz) > $r2 )
          $szfont --;
       else
          $loop ++;
    }

    $this->SetLineWidth(0.1);
    $this->SetFillColor(192);
    $this->RoundedRect($r1, $y1, ($r2 - $r1), $y2, 2.5, 'DF');
    $this->SetXY( $r1+1, $y1+2);
    $this->Cell($r2-$r1 -1,5, $texte, 0, 0, "C" );
}

// Estimate
function addDevis( $numdev )
{
	$string = sprintf("DEV%04d",$numdev);
	$this->fact_dev( "Devis", $string );
}

// Invoice
function addFacture( $numfact )
{
	$string = sprintf("FA%04d",$numfact);
	$this->fact_dev( "Facture", $string );
}

function addDate( $date, $label = "Forfallsdato" )
{
	$r1  = $this->w - 61;
	$r2  = $r1 + 30;
	$y1  = 17;
	$y2  = $y1 ;
	$mid = $y1 + ($y2 / 2);
	$this->RoundedRect($r1, $y1, ($r2 - $r1), $y2, 3.5, 'D');
	$this->Line( $r1, $mid, $r2, $mid);
	$this->SetXY( $r1 + ($r2-$r1)/2 - 5, $y1+3 );
	$this->SetFont( "Helvetica", "B", 10);
	$this->Cell(10,5, $label, 0, 0, "C");
	$this->SetXY( $r1 + ($r2-$r1)/2 - 5, $y1+9 );
	$this->SetFont( "Helvetica", "", 10);
	$this->Cell(10,5,$date, 0,0, "C");
}

function addClient( $ref )
{
	$r1  = $this->w - 31;
	$r2  = $r1 + 19;
	$y1  = 17;
	$y2  = $y1;
	$mid = $y1 + ($y2 / 2);
	$this->RoundedRect($r1, $y1, ($r2 - $r1), $y2, 3.5, 'D');
	$this->Line( $r1, $mid, $r2, $mid);
	$this->SetXY( $r1 + ($r2-$r1)/2 - 5, $y1+3 );
	$this->SetFont( "Helvetica", "B", 10);
	$this->Cell(10,5, "KUNDE", 0, 0, "C");
	$this->SetXY( $r1 + ($r2-$r1)/2 - 5, $y1 + 9 );
	$this->SetFont( "Helvetica", "", 10);
	$this->Cell(10,5,$ref, 0,0, "C");
}

function addPageNumber( $page )
{
	$r1  = $this->w - 80;
	$r2  = $r1 + 19;
	$y1  = 17;
	$y2  = $y1;
	$mid = $y1 + ($y2 / 2);
	$this->RoundedRect($r1, $y1, ($r2 - $r1), $y2, 3.5, 'D');
	$this->Line( $r1, $mid, $r2, $mid);
	$this->SetXY( $r1 + ($r2-$r1)/2 - 5, $y1+3 );
	$this->SetFont( "Helvetica", "B", 10);
	$this->Cell(10,5, "SIDE", 0, 0, "C");
	$this->SetXY( $r1 + ($r2-$r1)/2 - 5, $y1 + 9 );
	$this->SetFont( "Helvetica", "", 10);
	$this->Cell(10,5,$page, 0,0, "C");
}

// Client address
function addClientAdresse( $adresse )
{
	$r1     = $this->w - 200;
	$r2     = $r1 + 68;
	$y1     = 40;
	$this->SetXY( $r1, $y1);
	$this->MultiCell( 60, 4, $adresse);
}


function addInvoiceinfo( $adresse )
{
	$r1     = $this->w - 80;
	$r2     = $r1 + 68;
	$y1     = 40;
	$this->SetXY( $r1, $y1);
	$this->MultiCell( 60, 4, $adresse);
}


function addInvoicevalues( $adresse )
{
	$r1     = $this->w - 53;
	$r2     = $r1 + 68;
	$y1     = 40;
	$this->SetXY( $r1, $y1);
	$this->MultiCell( 60, 4, $adresse);
}


// Mode of payment
function addReglement( $mode )
{
	$r1  = 10;
	$r2  = $r1 + 60;
	$y1  = 80;
	$y2  = $y1+10;
	$mid = $y1 + (($y2-$y1) / 2);
	$this->RoundedRect($r1, $y1, ($r2 - $r1), ($y2-$y1), 2.5, 'D');
	$this->Line( $r1, $mid, $r2, $mid);
	$this->SetXY( $r1 + ($r2-$r1)/2 -5 , $y1+1 );
	$this->SetFont( "Helvetica", "B", 10);
	$this->Cell(10,4, "MODE DE REGLEMENT", 0, 0, "C");
	$this->SetXY( $r1 + ($r2-$r1)/2 -5 , $y1 + 5 );
	$this->SetFont( "Helvetica", "", 10);
	$this->Cell(10,5,$mode, 0,0, "C");
}

// Expiry date
function addEcheance( $date )
{
	$r1  = 80;
	$r2  = $r1 + 40;
	$y1  = 80;
	$y2  = $y1+10;
	$mid = $y1 + (($y2-$y1) / 2);
	$this->RoundedRect($r1, $y1, ($r2 - $r1), ($y2-$y1), 2.5, 'D');
	$this->Line( $r1, $mid, $r2, $mid);
	$this->SetXY( $r1 + ($r2 - $r1)/2 - 5 , $y1+1 );
	$this->SetFont( "Helvetica", "B", 10);
	$this->Cell(10,4, "Forfallsdato", 0, 0, "C");
	$this->SetXY( $r1 + ($r2-$r1)/2 - 5 , $y1 + 5 );
	$this->SetFont( "Helvetica", "", 10);
	$this->Cell(10,5,$date, 0,0, "C");
}

// VAT number
function addNumTVA($tva)
{
	$this->SetFont( "Helvetica", "B", 10);
	$r1  = $this->w - 80;
	$r2  = $r1 + 70;
	$y1  = 80;
	$y2  = $y1+10;
	$mid = $y1 + (($y2-$y1) / 2);
	$this->RoundedRect($r1, $y1, ($r2 - $r1), ($y2-$y1), 2.5, 'D');
	$this->Line( $r1, $mid, $r2, $mid);
	$this->SetXY( $r1 + 16 , $y1+1 );
	$this->Cell(40, 4, "ORG.nr.", '', '', "C");
	$this->SetFont( "Helvetica", "", 10);
	$this->SetXY( $r1 + 16 , $y1+5 );
	$this->Cell(40, 5, $tva, '', '', "C");
}

function addReference($ref)
{
	$this->SetFont( "Helvetica", "", 10);
	$length = $this->GetStringWidth( "" . $ref );
	$r1  = 9;
	$r2  = $r1 + $length;
	$y1  = 69;
	$y2  = $y1+5;
	$this->SetXY( $r1 , $y1 );
	$this->Cell($length,4, "" . $ref);
}

function addCols( $tab )
{
	global $colonnes;
	
	$r1  = 10;
	$r2  = $this->w - ($r1 * 2) ;
	$y1  = 75;
	$y2  = $this->h - 50 - $y1;
	$this->SetXY( $r1, $y1 );
	$this->Rect( $r1, $y1, $r2, $y2, "D"); // border
	$this->Line( $r1, $y1+6, $r1+$r2, $y1+6); // horizontal line
	$colX = $r1;
	$colonnes = $tab;
	while ( list( $lib, $pos ) = each ($tab) )
	{
		$this->SetXY( $colX, $y1+2 );
		$this->Cell( $pos, 1, $lib, 0, 0, "C");
		$colX += $pos;
		$this->Line( $colX, $y1, $colX, $y1+$y2); // vertical lines
	}
}

function addColsfaktura($tab,$hightadj)
{
	global $colonnes;
	
	$r1  = 10;
	$r2  = $this->w - ($r1 * 2) ;
	$y1  = 75;
	$y2  = $this->h - 130 - $hightadj - $y1;
	$this->SetXY( $r1, $y1 );
	$this->Rect( $r1, $y1, $r2, $y2, "D"); // border
	$this->Line( $r1, $y1+6, $r1+$r2, $y1+6); // horizontal line
	$colX = $r1;
	$colonnes = $tab;
	while ( list( $lib, $pos ) = each ($tab) )
	{
		$this->SetXY( $colX, $y1+2 );
		$this->Cell( $pos, 1, $lib, 0, 0, "C");
		$colX += $pos;
		$this->Line( $colX, $y1, $colX, $y1+$y2); // vertical lines
	}
}


function addLineFormat( $tab )
{
	global $format, $colonnes;
	
	while ( list( $lib, $pos ) = each ($colonnes) )
	{
		if ( isset( $tab["$lib"] ) )
			$format[ $lib ] = $tab["$lib"];
	}
}

function lineVert( $tab )
{
	global $colonnes;

	reset( $colonnes );
	$maxSize=0;
	while ( list( $lib, $pos ) = each ($colonnes) )
	{
		$texte = $tab[ $lib ];
		$longCell  = $pos -2;
		$size = $this->sizeOfText( $texte, $longCell );
		if ($size > $maxSize)
			$maxSize = $size;
	}
	return $maxSize;
}

// add a line to the invoice/estimate
/*    $ligne = array( "REFERENCE"    => $prod["ref"],
                      "DESIGNATION"  => $libelle,
                      "QUANTITE"     => sprintf( "%.2f", $prod["qte"]) ,
                      "P.U. HT"      => sprintf( "%.2f", $prod["px_unit"]),
                      "MONTANT H.T." => sprintf ( "%.2f", $prod["qte"] * $prod["px_unit"]) ,
                      "TVA"          => $prod["tva"] );
*/
function addLine( $ligne, $tab, $lineformat = "%0.2f")
{
	global $colonnes, $format;

	$ordonnee     = 10;
	$maxSize      = $ligne;
	$newtexte     = "";

	reset( $colonnes );
	while ( list( $lib, $pos ) = each ($colonnes) )
	{
		$longCell  = $pos -2;
		$texte     = $tab[ $lib ];
		$length    = $this->GetStringWidth( $texte );
		$tailleTexte = $this->sizeOfText( $texte, $length );
		$formText  = $format[ $lib ];
		$this->SetXY( $ordonnee, $ligne-1);
		$allign = 'L';

		if ($lib == "PRODUKT") {
		   if ($texte === "Til 8XXX Spesialsamtaler") { $texte = 'tttttttt'; }
		  // $texte = 'aaa';
	    }
		if ($lib == "ANTALL") {
		   $allign = 'R';
	    }
		if ($lib == "MINUTTER") {
		   $allign = 'R';
		   if ($texte == 0) { $texte = " "; }
		   else { $texte = sprintf($lineformat, $texte); }
	    }
		if ($lib == "BELØP") {
		   $allign = 'R';
		   if ($texte == 0) { $texte = " "; }
		   else { $texte = sprintf("%0.2f", $texte); }
	    }

		// $texte = $lib;
	    $this->MultiCell( $longCell, 4 , $texte, 0,$allign, $formText);
// 		$this->MultiCell( $longCell, 4 , $texte, 0, $formText);

//sprintf("%0.2f", $totalTTC)

		if ( $maxSize < ($this->GetY()  ) )
			$maxSize = $this->GetY() ;
		$ordonnee += $pos;
	}
	return ( $maxSize - $ligne );
}

function addRemarque($remarque)
{
	$this->SetFont( "Helvetica", "", 10);
	$length = $this->GetStringWidth( "" . $remarque ); // Remarque : text
	$r1  = 10;
	$r2  = $r1 + $length;
	$y1  = $this->h - 45.5;
	$y2  = $y1+5;
	$this->SetXY( $r1 , $y1 );
	$this->Cell($length,4, "" . $remarque); // Remarque : text
}

function addCadreTVAs()
{
	$this->SetFont( "Arial", "B", 8);
	$r1  = 10;
	$r2  = $r1 + 120;
	$y1  = $this->h - 40;
	$y2  = $y1+20;
	$this->RoundedRect($r1, $y1, ($r2 - $r1), ($y2-$y1), 2.5, 'D');
	$this->Line( $r1, $y1+4, $r2, $y1+4);
	$this->Line( $r1+5,  $y1+4, $r1+5, $y2); // avant BASES HT
	$this->Line( $r1+27, $y1, $r1+27, $y2);  // avant REMISE
	$this->Line( $r1+43, $y1, $r1+43, $y2);  // avant MT TVA
	$this->Line( $r1+63, $y1, $r1+63, $y2);  // avant % TVA
	$this->Line( $r1+75, $y1, $r1+75, $y2);  // avant PORT
	$this->Line( $r1+91, $y1, $r1+91, $y2);  // avant TOTAUX
	$this->SetXY( $r1+9, $y1);
	$this->Cell(10,4, "BASES HT");
	$this->SetX( $r1+29 );
	$this->Cell(10,4, "FRAKT");
	$this->SetX( $r1+48 );
	$this->Cell(10,4, "MT TVA");
	$this->SetX( $r1+63 );
	$this->Cell(10,4, "% TVA");
	$this->SetX( $r1+78 );
	$this->Cell(10,4, "PORT");
	$this->SetX( $r1+100 );
	$this->Cell(10,4, "TOTALT");
	$this->SetFont( "Arial", "B", 6);
	$this->SetXY( $r1+93, $y2 - 8 );
	$this->Cell(6,0, "H.T.   :");
	$this->SetXY( $r1+93, $y2 - 3 );
	$this->Cell(6,0, "T.V.A. :");
}

function addCadreEurosFrancs()
{
	$r1  = $this->w - 55;
	$r2  = $r1 + 45;
	$y1  = $this->h - 40;
	$y2  = $y1+20;
	$this->RoundedRect($r1, $y1, ($r2 - $r1), ($y2-$y1), 2.5, 'D');
	$this->Line( $r1+20,  $y1, $r1+20, $y2); // avant EUROS
	$this->Line( $r1+20, $y1+4, $r2, $y1+4); // Sous Euros & Francs
	
	//$this->Line( $r1+38,  $y1, $r1+38, $y2); // Entre Euros & Francs
	
	$this->SetFont( "Arial", "B", 8);
	$this->SetXY( $r1+22, $y1 );
	$this->Cell(21,4, "KRONER", 0, 0, "R");
	
	/*
	$this->SetFont( "Arial", "", 8);
	$this->SetXY( $r1+22, $y1 );
	$this->Cell(15,4, "FRANCE", 0, 0, "C");
	*/
	
	$this->SetFont( "Arial", "B", 8);
	$this->SetXY( $r1, $y1+5 );
	$this->Cell(20,4, "SUM", 0, 0, "C");
	$this->SetXY( $r1, $y1+10 );
	$this->Cell(20,4, "MVA", 0, 0, "C");
	$this->SetXY( $r1, $y1+15 );
	$this->Cell(20,4, "TOTAL SUM", 0, 0, "C");
}

// remplit les cadres TVA / Totaux et la remarque
// params  = array( "RemiseGlobale" => [0|1],
//                      "remise_tva"     => [1|2...],  // {la remise s'applique sur ce code TVA}
//                      "remise"         => value,     // {montant de la remise}
//                      "remise_percent" => percent,   // {pourcentage de remise sur ce montant de TVA}
//                  "FraisPort"     => [0|1],
//                      "portTTC"        => value,     // montant des frais de ports TTC
//                                                     // par defaut la TVA = 19.6 %
//                      "portHT"         => value,     // montant des frais de ports HT
//                      "portTVA"        => tva_value, // valeur de la TVA a appliquer sur le montant HT
//                  "AccompteExige" => [0|1],
//                      "accompte"         => value    // montant de l'acompte (TTC)
//                      "accompte_percent" => percent  // pourcentage d'acompte (TTC)
//                  "Remarque" => "texte"              // texte
// tab_tva = array( "1"       => 19.6,
//                  "2"       => 5.5, ... );
// invoice = array( "px_unit" => value,
//                  "qte"     => qte,
//                  "tva"     => code_tva );

function addTVAs3Bankgiro( $invoiceprice, $mva, $totalsum,$hightadj )
{
	$x1 = -38;
	$y1 = -129-$hightadj;

	$this->SetFont( "Arial", "B", 8);
	$this->SetXY( $x1, $y1+5 );
	$this->Cell(26,4, sprintf("%0.2f",$invoiceprice), 0, 0, "R");
	$this->SetXY( $x1, $y1+10 );
	$this->Cell(26,4, sprintf("%0.2f",$mva), 0, 0, "R");
	$this->SetXY( $x1, $y1+15 );
	$this->Cell(26,4, sprintf("%0.2f",$totalsum), 0, 0, "R");

	$r1  = $this->w - 55;
	$r2  = $r1 + 45;
	$y1  = $this->h - 129-$hightadj;
	$y2  = $y1+20;
	$this->RoundedRect($r1, $y1, ($r2 - $r1), ($y2-$y1), 2.5, 'D');
	$this->Line( $r1+20,  $y1, $r1+20, $y2); // avant EUROS
	$this->Line( $r1+20, $y1+4, $r2, $y1+4); // Sous Euros & Francs
	
	//$this->Line( $r1+38,  $y1, $r1+38, $y2); // Entre Euros & Francs
	
	$this->SetFont( "Arial", "B", 8);
	$this->SetXY( $r1+22, $y1 );
	$this->Cell(21,4, "KRONER", 0, 0, "R");
	
	/*
	$this->SetFont( "Arial", "", 8);
	$this->SetXY( $r1+22, $y1 );
	$this->Cell(15,4, "FRANCE", 0, 0, "C");
	*/
	
	$this->SetFont( "Arial", "B", 8);
	$this->SetXY( $r1, $y1+5 );
	$this->Cell(20,4, "SUM", 0, 0, "C");
	$this->SetXY( $r1, $y1+10 );
	$this->Cell(20,4, "MVA", 0, 0, "C");
	$this->SetXY( $r1, $y1+15 );
	$this->Cell(20,4, "TOTAL SUM", 0, 0, "C");
}


function addTVAs2( $invoiceprice, $mva, $totalsum )
{
	$x1 = -38;
	$y1 = -40;

	$this->SetFont( "Arial", "B", 8);
	$this->SetXY( $x1, $y1+5 );
	$this->Cell(26,4, sprintf("%0.2f",$invoiceprice), 0, 0, "R");
	$this->SetXY( $x1, $y1+10 );
	$this->Cell(26,4, sprintf("%0.2f",$mva), 0, 0, "R");
	$this->SetXY( $x1, $y1+15 );
	$this->Cell(26,4, sprintf("%0.2f",$totalsum), 0, 0, "R");
}

function addTVAs( $params, $tab_tva, $invoice )
{
	$this->SetFont('Arial','',8);
	
	reset ($invoice);
	$px = array();
	while ( list( $k, $prod) = each( $invoice ) )
	{
		$tva = $prod["tva"];
		@ $px[$tva] += $prod["qte"] * $prod["px_unit"];
	}

	$prix     = array();
	$totalHT  = 0;
	$totalTTC = 0;
	$totalTVA = 0;
	$y = 261;
	reset ($px);
	natsort( $px );
	while ( list($code_tva, $articleHT) = each( $px ) )
	{
		$tva = $tab_tva[$code_tva];
		$this->SetXY(17, $y);
		$this->Cell( 19,4, sprintf("%0.2f", $articleHT),'', '','R' );
		if ( $params["RemiseGlobale"]==1 )
		{
			if ( $params["remise_tva"] == $code_tva )
			{
				$this->SetXY( 37.5, $y );
				if ($params["remise"] > 0 )
				{
					if ( is_int( $params["remise"] ) )
						$l_remise = $param["remise"];
					else
						$l_remise = sprintf ("%.02f", $params["remise"]);
					$this->Cell( 14.5,4, $l_remise, '', '', 'R' );
					$articleHT -= $params["remise"];
				}
				else if ( $params["remise_percent"] > 0 )
				{
					$rp = $params["remise_percent"];
					if ( $rp > 1 )
						$rp /= 100;
					$rabais = $articleHT * $rp;
					$articleHT -= $rabais;
					if ( is_int($rabais) )
						$l_remise = $rabais;
					else
						$l_remise = sprintf ("%.02f", $rabais);
					$this->Cell( 14.5,4, $l_remise, '', '', 'R' );
				}
				else
					$this->Cell( 14.5,4, "ErrorRem", '', '', 'R' );
			}
		}
		$totalHT += $articleHT;
		$totalTTC += $articleHT * ( 1 + $tva/100 );
		$tmp_tva = $articleHT * $tva/100;
		$a_tva[ $code_tva ] = $tmp_tva;
		$totalTVA += $tmp_tva;
		$this->SetXY(11, $y);
		$this->Cell( 5,4, $code_tva);
		$this->SetXY(53, $y);
		$this->Cell( 19,4, sprintf("%0.2f",$tmp_tva),'', '' ,'R');
		$this->SetXY(74, $y);
		$this->Cell( 10,4, sprintf("%0.2f",$tva) ,'', '', 'R');
		$y+=4;
	}

	if ( $params["FraisPort"] == 1 )
	{
		if ( $params["portTTC"] > 0 )
		{
			$pTTC = sprintf("%0.2f", $params["portTTC"]);
			$pHT  = sprintf("%0.2f", $pTTC / 1.196);
			$pTVA = sprintf("%0.2f", $pHT * 0.196);
			$this->SetFont('Arial','',6);
			$this->SetXY(85, 261 );
			$this->Cell( 6 ,4, "HT : ", '', '', '');
			$this->SetXY(92, 261 );
			$this->Cell( 9 ,4, $pHT, '', '', 'R');
			$this->SetXY(85, 265 );
			$this->Cell( 6 ,4, "TVA : ", '', '', '');
			$this->SetXY(92, 265 );
			$this->Cell( 9 ,4, $pTVA, '', '', 'R');
			$this->SetXY(85, 269 );
			$this->Cell( 6 ,4, "TTC : ", '', '', '');
			$this->SetXY(92, 269 );
			$this->Cell( 9 ,4, $pTTC, '', '', 'R');
			$this->SetFont('Arial','',8);
			$totalHT += $pHT;
			$totalTVA += $pTVA;
			$totalTTC += $pTTC;
		}
		else if ( $params["portHT"] > 0 )
		{
			$pHT  = sprintf("%0.2f", $params["portHT"]);
			$pTVA = sprintf("%0.2f", $params["portTVA"] * $pHT / 100 );
			$pTTC = sprintf("%0.2f", $pHT + $pTVA);
			$this->SetFont('Arial','',6);
			$this->SetXY(85, 261 );
			$this->Cell( 6 ,4, "HT : ", '', '', '');
			$this->SetXY(92, 261 );
			$this->Cell( 9 ,4, $pHT, '', '', 'R');
			$this->SetXY(85, 265 );
			$this->Cell( 6 ,4, "TVA : ", '', '', '');
			$this->SetXY(92, 265 );
			$this->Cell( 9 ,4, $pTVA, '', '', 'R');
			$this->SetXY(85, 269 );
			$this->Cell( 6 ,4, "TTC : ", '', '', '');
			$this->SetXY(92, 269 );
			$this->Cell( 9 ,4, $pTTC, '', '', 'R');
			$this->SetFont('Arial','',8);
			$totalHT += $pHT;
			$totalTVA += $pTVA;
			$totalTTC += $pTTC;
		}
	}

	$this->SetXY(114,266.4);
	$this->Cell(15,4, sprintf("%0.2f", $totalHT), '', '', 'R' );
	$this->SetXY(114,271.4);
	$this->Cell(15,4, sprintf("%0.2f", $totalTVA), '', '', 'R' );

	$params["totalHT"] = $totalHT;
	$params["TVA"] = $totalTVA;
	$accompteTTC=0;
	if ( $params["AccompteExige"] == 1 )
	{
		if ( $params["accompte"] > 0 )
		{
			$accompteTTC=sprintf ("%.2f", $params["accompte"]);
			if ( strlen ($params["Remarque"]) == 0 )
				$this->addRemarque( "Accompte de $accompteTTC Euros exigé à la commande.");
			else
				$this->addRemarque( $params["Remarque"] );
		}
		else if ( $params["accompte_percent"] > 0 )
		{
			$percent = $params["accompte_percent"];
			if ( $percent > 1 )
				$percent /= 100;
			$accompteTTC=sprintf("%.2f", $totalTTC * $percent);
			$percent100 = $percent * 100;
			if ( strlen ($params["Remarque"]) == 0 )
				$this->addRemarque( "Accompte de $percent100 % (soit $accompteTTC Euros) exigé à la commande." );
			else
				$this->addRemarque( $params["Remarque"] );
		}
		else
			$this->addRemarque( "Drôle d'acompte !!! " . $params["Remarque"]);
	}
	else
	{
		if ( strlen ($params["Remarque"]) > 0 )
			$this->addRemarque( $params["Remarque"] );
	}
	$re  = $this->w - 50;
	$rf  = $this->w - 29;
	$y1  = $this->h - 40;
	$this->SetFont( "Arial", "", 8);
	$this->SetXY( $re, $y1+5 );
	$this->Cell( 29,4, sprintf("%0.2f", $totalTTC), '', '', 'R');
	$this->SetXY( $re, $y1+10 );
	$this->Cell( 29,4, sprintf("%0.2f", $accompteTTC), '', '', 'R');
	$this->SetXY( $re, $y1+14.8 );
	$this->Cell( 29,4, sprintf("%0.2f", $totalTTC - $accompteTTC), '', '', 'R');
/*
	$this->SetXY( $rf, $y1+5 );
	$this->Cell( 17,4, sprintf( "%0.2f", $totalTTC * EURO_VAL), '', '', 'R');
	$this->SetXY( $rf, $y1+10 );
	$this->Cell( 17,4, sprintf("%0.2f", $accompteTTC * EURO_VAL), '', '', 'R');
	$this->SetXY( $rf, $y1+14.8 );
	$this->Cell( 17,4, sprintf("%0.2f", ($totalTTC - $accompteTTC) * EURO_VAL), '', '', 'R');
*/
}

// add a watermark (temporary estimate, DUPLICATA...)
// call this method first
function temporaire( $texte )
{
	$this->SetFont('Arial','B',50);
	$this->SetTextColor(203,203,203);
	$this->Rotate(45,55,190);
	$this->Text(65,160,$texte);
	$this->Rotate(0);
	$this->SetTextColor(0,0,0);
}

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


}

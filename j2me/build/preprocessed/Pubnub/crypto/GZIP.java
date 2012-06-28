package Pubnub.crypto;

import java.io.*;

public class GZIP
{
	// M�scaras para el flag.
	private static final int FTEXT_MASK		= 1;
	private static final int FHCRC_MASK		= 2;
	private static final int FEXTRA_MASK	= 4;
	private static final int FNAME_MASK		= 8;
	private static final int FCOMMENT_MASK	= 16;
	// Tipos de bloques.
	private static final int BTYPE_NONE		= 0;
	private static final int BTYPE_FIXED	= 1;
	private static final int BTYPE_DYNAMIC	= 2;
	private static final int BTYPE_RESERVED	= 3;
	// L�mites.
	private static final int MAX_BITS			= 16;
	private static final int MAX_CODE_LITERALS	= 287;
	private static final int MAX_CODE_DISTANCES	= 31;
	private static final int MAX_CODE_LENGTHS	= 18;
	private static final int EOB_CODE			= 256;
	// Datos prefijados (LENGTH: 257..287 / DISTANCE: 0..29 / DYNAMIC_LENGTH_ORDER: 0..18).
	private static final int LENGTH_EXTRA_BITS[]    = {0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0,99,99};
	private static final int LENGTH_VALUES[]        = {3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258,0,0};
	private static final int DISTANCE_EXTRA_BITS[]  = {0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13};
	private static final int DISTANCE_VALUES[]      = {1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577};
	private static final int DYNAMIC_LENGTH_ORDER[] = {16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15};

	/*************************************************************************/

	// Variables para la lectura de datos comprimidos.
	private static int gzipIndex,gzipByte,gzipBit;

	/*************************************************************************/
	/*************************************************************************/

	/**
	 * Descomprime un fichero GZIP.
	 *
	 * @param gzip Array con los datos del fichero comprimido
	 *
	 * @return Array con los datos descomprimidos
	 */
	public static byte[] inflate(byte gzip[]) throws IOException
	{
		// Inicializa.
		gzipIndex=gzipByte=gzipBit=0;
		// Cabecera.
		if (readBits(gzip,16)!=0x8B1F||readBits(gzip,8)!=8) throw new IOException("Invalid GZIP format");
		// Flag.
		int flg=readBits(gzip,8);
		// Fecha(4) / XFL(1) / OS(1).
		gzipIndex+=6;
		// Comprueba los flags.
		if ((flg&FEXTRA_MASK)!=0) gzipIndex+=readBits(gzip,16);
		if ((flg&FNAME_MASK)!=0) while (gzip[gzipIndex++]!=0);
		if ((flg&FCOMMENT_MASK)!=0) while (gzip[gzipIndex++]!=0);
		if ((flg&FHCRC_MASK)!=0) gzipIndex+=2;
		// Tama�o de los datos descomprimidos.
		int index=gzipIndex;
		gzipIndex=gzip.length-4;
		byte uncompressed[]=new byte[readBits(gzip,16)|(readBits(gzip,16)<<16)];
		int uncompressedIndex=0;
		gzipIndex=index;
		// Bloque con datos comprimidos.
		int bfinal=0,btype=0;
		do
		{
			// Lee la cabecera del bloque.
			bfinal=readBits(gzip,1);
			btype=readBits(gzip,2);
			// Comprueba el tipo de compresi�n.
			if (btype==BTYPE_NONE)
			{
				// Ignora los bits dentro del byte actual.
				gzipBit=0;
				// LEN.
				int len=readBits(gzip,16);
				// NLEN.
				int nlen=readBits(gzip,16);
				// Lee los datos.
				System.arraycopy(gzip,gzipIndex,uncompressed,uncompressedIndex,len);
				gzipIndex+=len;
				// Actualiza el �ndice de los datos descomprimidos.
				uncompressedIndex+=len;
			}
			else
			{
				int literalTree[],distanceTree[];
				if (btype==BTYPE_DYNAMIC)
				{
					// N�mero de datos de cada tipo.
					int hlit=readBits(gzip,5)+257;
					int hdist=readBits(gzip,5)+1;
					int hclen=readBits(gzip,4)+4;
					// Lee el n�mero de bits para cada c�digo de longitud.
					byte lengthBits[]=new byte[MAX_CODE_LENGTHS+1];
					for (int i=0;i<hclen;i++) lengthBits[DYNAMIC_LENGTH_ORDER[i]]=(byte)readBits(gzip,3);
					// Crea los c�digos para la longitud.
					int lengthTree[]=createHuffmanTree(lengthBits,MAX_CODE_LENGTHS);
					// Genera los �rboles.
					literalTree=createHuffmanTree(decodeCodeLengths(gzip,lengthTree,hlit),hlit-1);
					distanceTree=createHuffmanTree(decodeCodeLengths(gzip,lengthTree,hdist),hdist-1);
				}
				else
				{
					byte literalBits[]=new byte[MAX_CODE_LITERALS+1];
					for (int i=0;i<144;i++) literalBits[i]=8;
					for (int i=144;i<256;i++) literalBits[i]=9;
					for (int i=256;i<280;i++) literalBits[i]=7;
					for (int i=280;i<288;i++) literalBits[i]=8;
					literalTree=createHuffmanTree(literalBits,MAX_CODE_LITERALS);
					//
					byte distanceBits[]=new byte[MAX_CODE_DISTANCES+1];
					for (int i=0;i<distanceBits.length;i++) distanceBits[i]=5;
					distanceTree=createHuffmanTree(distanceBits,MAX_CODE_DISTANCES);
				}
				// Descomprime el bloque.
				int code=0,leb=0,deb=0;
				while ((code=readCode(gzip,literalTree))!=EOB_CODE)
				{
					if (code>EOB_CODE)
					{
						code-=257;
						int length=LENGTH_VALUES[code];
						if ((leb=LENGTH_EXTRA_BITS[code])>0) length+=readBits(gzip,leb);
						code=readCode(gzip,distanceTree);
						int distance=DISTANCE_VALUES[code];
						if ((deb=DISTANCE_EXTRA_BITS[code])>0) distance+=readBits(gzip,deb);
						// Repite la informaci�n.
						int offset=uncompressedIndex-distance;
						while (distance<length)
						{
							System.arraycopy(uncompressed,offset,uncompressed,uncompressedIndex,distance);
							uncompressedIndex+=distance;
							length-=distance;
							distance<<=1;
						}
						System.arraycopy(uncompressed,offset,uncompressed,uncompressedIndex,length);
						uncompressedIndex+=length;
					}
					else uncompressed[uncompressedIndex++]=(byte)code;
				}
			}
		}
		while (bfinal==0);
		//
		return uncompressed;
	}

	/**
	 * Lee un n�mero de bits
	 *
	 * @param n N�mero de bits [0..16]
	 */
	private static int readBits(byte gzip[],int n)
	{
		// Asegura que tenemos un byte.
		int data=(gzipBit==0?(gzipByte=(gzip[gzipIndex++]&0xFF)):(gzipByte>>gzipBit));
		// Lee hasta completar los bits.
		for (int i=(8-gzipBit);i<n;i+=8)
		{
			gzipByte=(gzip[gzipIndex++]&0xFF);
			data|=(gzipByte<<i);
		}
		// Ajusta la posici�n actual.
		gzipBit=(gzipBit+n)&7;
		// Devuelve el dato.
		return (data&((1<<n)-1));
	}

	/**
	 * Lee un c�digo.
	 */
	private static int readCode(byte gzip[],int tree[])
	{
		int node=tree[0];
		while (node>=0)
		{
			// Lee un byte si es necesario.
			if (gzipBit==0) gzipByte=(gzip[gzipIndex++]&0xFF);
			// Accede al nodo correspondiente.
			node=(((gzipByte&(1<<gzipBit))==0)?tree[node>>16]:tree[node&0xFFFF]);
			// Ajusta la posici�n actual.
			gzipBit=(gzipBit+1)&7;
		}
		return (node&0xFFFF);
	}

	/**
	 * Decodifica la longitud de c�digos (usado en bloques comprimidos con c�digos din�micos).
	 */
	private static byte[] decodeCodeLengths(byte gzip[],int lengthTree[],int count)
	{
		byte bits[]=new byte[count];
		for (int i=0,code=0,last=0;i<count;)
		{
			code=readCode(gzip,lengthTree);
			if (code>=16)
			{
				int repeat=0;
				if (code==16)
				{
					repeat=3+readBits(gzip,2);
					code=last;
				}
				else
				{
					if (code==17) repeat=3+readBits(gzip,3);
						else repeat=11+readBits(gzip,7);
					code=0;
				}
				while (repeat-->0) bits[i++]=(byte)code;
			}
			else bits[i++]=(byte)code;
			//
			last=code;
		}
		return bits;
	}

	/**
	 * Crea el �rbol para los c�digos Huffman.
	 */
	private static int[] createHuffmanTree(byte bits[],int maxCode)
	{
		// N�mero de c�digos por cada longitud de c�digo.
		int bl_count[]=new int[MAX_BITS+1];
		for (int i=0;i<bits.length;i++) bl_count[bits[i]]++;
		// M�nimo valor num�rico del c�digo para cada longitud de c�digo.
		int code=0;
		bl_count[0]=0;
		int next_code[]=new int[MAX_BITS+1];
		for (int i=1;i<=MAX_BITS;i++) next_code[i]=code=(code+bl_count[i-1])<<1;
		// Genera el �rbol.
		// Bit 31 => Nodo (0) o c�digo (1).
		// (Nodo) bit 16..30 => �ndice del nodo de la izquierda (0 si no tiene).
		// (Nodo) bit 0..15 => �ndice del nodo de la derecha (0 si no tiene).
		// (C�digo) bit 0..15
		int tree[]=new int[(maxCode<<1)+MAX_BITS];
		int treeInsert=1;
		for (int i=0;i<=maxCode;i++)
		{
			int len=bits[i];
			if (len!=0)
			{
				code=next_code[len]++;
				// Lo mete en en �rbol.
				int node=0;
				for (int bit=len-1;bit>=0;bit--)
				{
					int value=code&(1<<bit);
					// Inserta a la izquierda.
					if (value==0)
					{
						int left=tree[node]>>16;
						if (left==0)
						{
							tree[node]|=(treeInsert<<16);
							node=treeInsert++;
						}
						else node=left;
					}
					// Inserta a la derecha.
					else
					{
						int right=tree[node]&0xFFFF;
						if (right==0)
						{
							tree[node]|=treeInsert;
							node=treeInsert++;
						}
						else node=right;
					}
				}
				// Inserta el c�digo.
				tree[node]=0x80000000|i;
			}
		}
		return tree;
	}
}
---- instructions ----

07 December 2011 updates:
- Added new sample DITA project
- Now supports correct xml:lang
  - - In your translated XLIFF file, add a target-language attribute on each <file> element and it will add an xml:lang attribute to each DITA file
      For example, search for:
      <file
      Replace with:
      <file target-language="de-DE"
- Now supports translate="no"
  - - If you set any DITA attribute of translate to "no", the XLIFF file will set the XLIFF target element to state="final"
      <target state="final">


Note DITA OT1.5.2 or later supported.

This plugin depends on:
demo/xliff/integrator.xml
demo/xliff/plugin.xml
demo/xliff/build_dita2xliff.xml
demo/xliff/xsl/d2x.xsl

demo/ditafromxliff/integrator.xml
demo/ditafromxliff/plugin.xml
demo/ditafromxliff/build_ditafromxliff.xml
demo/ditafromxliff/xsl/x2d.xsl

Note: For first time, after installation, remember to run 'ant -f integrator.xml'

Note: To run DITA to XLIFF or XLIFF to DITA, access the correct command tool by first executing the startcmd.bat or startcmd.sh file in the root directory of the DITA OT.


Instruction for running the beta version of DITA-XLIFF Roundtrip Tool for the Open Toolkit

These instructions will provide a starting point. You can use the samples and just leave everything else as is. Or you can use your own DITA sample projects and do more robust testing. To do that you will need to edit the integrator and build files.

DITA to XLIFF sample

1. unzip each of the attached files in the DITA-OT1.5.2/demo directory
2. go to the demo/xliff directory
3. in the DITA OT command window, execute: ant -f integrator.xml (only need to do this once)
4. take a look in the demo/xliff/ComstartUserGuide folder and note the ConstarUserGuide.ditamap. The build file is pointed at this map in the sample
5. at the demo/xliff directory, execute ant -f build_dita2xliff.xml
6. go to the demo\xliff\out\samples\xliff. Note the d_x.xml file. This is a valid XLIFF file that has all your maps, topics, and
   required structure to translate and reassemble your DITA project. Feel free to translate it with your favorite XLIFF editor
Note: if your CAT tool uses custome extensions, you may need to include its XML Schema in the XLIFF to DITA step.
7. change the name of the translated file to d_x_translated.xml, and place it in the demo\ditafromxliff\in directory


XLIFF to DITA sample

1. go to the demo\ditafromxliff\in directory
2. in the DITA OT command window, execute: ant -f integrator.xml (only need to do this once)
3. take a look at the d_x_translated.xml file. This is the same file you just translated. The build file
   is pointed at this XLIFF file (please also note the two schemas. They are needed by saxon9)
4. at the demo/ditafromxliff directory, execute ant -f build_ditafromxliff.xml
5. go to the demo/ditafromxliff/out/samples/ditafromxliff directory. Look in the translated folder. You will find your translated
   DITA project
6. (small bug) if you want to re-run this step, you must first remove the deleteme.txt file (or just double-click the must-clean4each-round.bat)

For more robust testing (please do - the more testing the better) you must edit a few files.

DITA to XLIFF (your files)

1. (recommended) put your project in the demo/xliff/samples directory (i.e., for example demo/xliff/birds)
2. in the demo/xliff/build_dita2xliff.xml file, edit this line (line 15)

            <property name="args.input" value="samples${file.separator}ComstartUserGuide${file.separator}ComstarUserGuide.ditamap"/>
to say
            <property name="args.input" value="samples${file.separator}birds${file.separator}birds.ditamap"/>
3. the follow the remaining steps as listed above

XLIFF to DITA (your files)
1. (recommended) translate your new XLIFF file, name it d_x_translated.xml, and put it in the demo\ditafromxliff\in directory
Note: make sure the schemas are there
Note: if you want to change file names or directory structure, you will need to edit the integrator.xml file, and the build_ditafromxliff.xml file.

Known limitations (I'm working on these)
1. You must delete the output file from the out directory each time you want to run ditafromxliff
2. If your main map links to map or topics not on adjacent to the map file, the results will work, but the nesting will be a little weird. I am working on a scheme that counts how many levels difference, and builds a deep hierarchy to accommodate.

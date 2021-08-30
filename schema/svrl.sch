<!--
Copyright © ISO/IEC 2014

The following permission notice and disclaimer shall be included in all
copies of this XML schema ("the Schema"), and derivations of the Schema:
Permission is hereby granted, free of charge in perpetuity, to any person obtaining a 
copy of the Schema, to use, copy, modify, merge and
distribute free of charge, copies of the Schema for the purposes of
developing, implementing, installing and using software based on the
Schema, and to permit persons to whom the Schema is furnished to do so,
subject to the following conditions:
THE SCHEMA IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SCHEMA OR THE USE OR
OTHER DEALINGS IN THE SCHEMA.
In addition, any modified copy of the Schema shall include the following
notice:
THIS SCHEMA HAS BEEN MODIFIED FROM THE SCHEMA DEFINED IN ISO/IEC 19757 3,
AND SHOULD NOT BE INTERPRETED AS COMPLYING WITH THAT STANDARD."
-->

<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xml:lang="en">
    <sch:title>Schema for Schematron Validation Report Language</sch:title>
    <sch:ns prefix="svrl" uri="http://purl.oclc.org/dsdl/svrl"/>
    <sch:p>The Schematron Validation Report Language is a simple language
        for implementations to use to compare their conformance. It is
        basically a list of all the assertions that fail when validating
        a document, in any order, together with other information such as
        which rules fire. </sch:p>
    <sch:p>This schema can be used to validate SVRL documents, and provides examples
        of the use of abstract rules and abstract patterns.</sch:p>
    <sch:pattern>
        <sch:title>Elements</sch:title>
        <!--Abstract Rules -->
        <sch:rule abstract="true" id="second-level">
            <sch:assert test="../svrl:schematron-output"> The <sch:name/> element is a
                child of schematron-output. </sch:assert>
        </sch:rule>
        <sch:rule abstract="true" id="childless">
            <sch:assert test="count(*)=0"> The <sch:name/> element should not contain 
                any elements.
            </sch:assert>
        </sch:rule>
        <sch:rule abstract="true" id="empty">
            <sch:extends rule="childless"/>
            <sch:assert test="string-length(normalize-space(.)) = 0"> The <sch:name/>
                element should be empty. </sch:assert>
        </sch:rule>
        <!-- Rules-->
        <sch:rule context="svrl:schematron-output">
            <sch:assert test="not(../*)"> The <sch:name/> element is the root element.
            </sch:assert>
            <sch:assert
                test="count(svrl:text) + count(svrl:ns-prefix-in-attribute-values) +count(svrl:fired-rule) + count(svrl:failed-assert) +
                count(svrl:successful-report) = count(*)">
                <sch:name/> may only contain the following elements: text,
                ns-prefix-in-attribute-values, active-pattern, fired-rule, failed-assert and
                successful-report. </sch:assert>
            <sch:assert test="svrl:active-pattern">
                <sch:name/> should have at least one active pattern. </sch:assert>
        </sch:rule>
        <sch:rule context="svrl:text">
            <sch:extends rule="childless"/>
        </sch:rule>
        <sch:rule context="svrl:diagnostic-reference">
            <sch:extends rule="childless"/>
            <sch:assert test="string-length(@diagnostic) &gt; 0">
                <sch:name/> should have a diagnostic attribute, giving the id of
                the diagnostic.
            </sch:assert>
        </sch:rule>
        <sch:rule context="svrl:ns-prefix-in-attribute-values">
            <sch:extends rule="second-level"/>
            <sch:extends rule="empty"/>
            <sch:assert
                test="following-sibling::svrl:active-pattern
                or following-sibling::svrl:ns-prefix-in-attribute-value"
                > A <sch:name/> comes before an active-pattern or another
                ns-prefix-in-attribute-values element. </sch:assert>
        </sch:rule>
        <sch:rule context="svrl:active-pattern">
            <sch:extends rule="second-level"/>
            <sch:extends rule="empty"/>
        </sch:rule>
        <sch:rule context="svrl:fired-rule">
            <sch:extends rule="second-level"/>
            <sch:extends rule="empty"/>
            <sch:assert
                test="preceding-sibling::active-pattern |
                preceding-sibling::svrl:fired-rule |
                preceding-sibling::svrl:failed-assert |
                preceding-sibling::svrl:successful-report"
                > A <sch:name/> comes after an active-pattern, an empty fired-rule,
                a failed-assert or a successful report. </sch:assert>
            <sch:assert test="string-length(@context) &gt; 0"> The <sch:name/> element
                should have a context attribute giving the current
                context, in simple XPath format. </sch:assert>
        </sch:rule>
        <sch:rule context="svrl:failed-assert | svrl:successful-report">
            <sch:extends rule="second-level"/>
            <sch:assert test="count(svrl:diagnostic-reference) + count(svrl:text) =
                count(*)"> The <sch:name/> element should only contain a
                text element and diagnostic reference elements. </sch:assert>
            <sch:assert test="count(svrl:text) = 1"> The <sch:name/> element should only
                contain a text element. </sch:assert>
            <sch:assert
                test="preceding-sibling::svrl:fired-rule |
                preceding-sibling::svrl:failed-assert |
                preceding-sibling::svrl:successful-report"
                > A <sch:name/> comes after a fired-rule, a failed-assert or a successful-
                report.
            </sch:assert>
        </sch:rule>
        <!-- Catch-all rule-->
        <sch:rule context="*">
            <sch:report test="true()"> An unknown <sch:name/> element has been used.
            </sch:report>
        </sch:rule>
    </sch:pattern>
    <sch:pattern>
        <sch:title>Unique Ids</sch:title>
        <sch:rule context="*[@id]">
            <sch:assert test="not(preceding::*[@id=current()/@id][1])"> Id attributes
                should be unique in a document. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern abstract="true" id="requiredAttribute">
        <sch:title>Required Attributes</sch:title>
        <sch:rule context=" $context ">
            <sch:assert test="string-length( $attribute ) &gt; 0"> The <sch:name/> element
                should have a <sch:value-of select="$attribute /name()"/> attribute.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern is-a="requiredAttribute">
        <sch:param name="context" value="svrl:diagnostic-reference"/>
        <sch:param name="attribute" value="@diagnostic"/>
    </sch:pattern>
    <sch:pattern is-a="requiredAttribute">
        <sch:param name="context" value="svrl:failed-assert |  svrl:successful-report"/>
        <sch:param name="attribute" value="@location"/>
    </sch:pattern>
    <sch:pattern is-a="requiredAttribute">
        <sch:param name="context" value="svrl:failed-assert | svrl:successful-report"/>
        <sch:param name="attribute" value="@test"/>
    </sch:pattern>
    <sch:pattern is-a="requiredAttribute">
        <sch:param name="context" value="svrl:ns-prefix-in-attribute-values"/>
        <sch:param name="attribute" value="@uri"/>
    </sch:pattern>
    <sch:pattern is-a="requiredAttribute">
        <sch:param name="context" value="svrl:ns-prefix-in-attribute-values"/>
        <sch:param name="attribute" value="@prefix"/>
    </sch:pattern>
</sch:schema>
import RDFCore
import RDFKit

/// The SHACL 1.2 node expression vocabulary, in the `shnex:` namespace.
///
/// A node expression is decoded from its parameters' terms; each term is a
/// Swift declaration whose IRI is read only while a shapes graph is decoded.
@Ontology
public struct SHNEX: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/ns/shacl-node-expr#")

        Property("nodes") {
            Type(RDF.Property)
            Label("nodes")
            Comment("The nodes the expression gives as input.")
        }

        Property("exists") {
            Type(RDF.Property)
            Label("exists")
            Comment("Whether the input expression has output.")
        }

        Property("count") {
            Type(RDF.Property)
            Label("count")
            Comment("The number of output nodes of the input expression.")
        }

        Property("var") {
            Type(RDF.Property)
            Label("var")
            Comment("The value of a variable in scope.")
        }

        Property("distinct") {
            Type(RDF.Property)
            Label("distinct")
            Comment("The output of the input expression without duplicates.")
        }

        Property("matchAll") {
            Type(RDF.Property)
            Label("matchAll")
            Comment("Whether every input node conforms to the shape.")
        }

        Property("filterShape") {
            Type(RDF.Property)
            Label("filterShape")
            Comment("The input nodes that conform to the shape.")
        }

        Property("instancesOf") {
            Type(RDF.Property)
            Label("instancesOf")
            Comment("The instances of the class.")
        }

        Property("nodesMatching") {
            Type(RDF.Property)
            Label("nodesMatching")
            Comment("The nodes of the data graph that conform to the shape.")
        }

        Property("min") {
            Type(RDF.Property)
            Label("min")
            Comment("The least output node of the input expression.")
        }

        Property("max") {
            Type(RDF.Property)
            Label("max")
            Comment("The greatest output node of the input expression.")
        }

        Property("sum") {
            Type(RDF.Property)
            Label("sum")
            Comment("The sum of the output nodes of the input expression.")
        }

        Property("if") {
            Type(RDF.Property)
            Label("if")
            Comment("The condition of a conditional expression.")
        }

        Property("then") {
            Type(RDF.Property)
            Label("then")
            Comment("The expression a conditional gives when its condition is true.")
        }

        Property("else") {
            Type(RDF.Property)
            Label("else")
            Comment("The expression a conditional gives when its condition is not true.")
        }

        Property("pathValues") {
            Type(RDF.Property)
            Label("pathValues")
            Comment("The values a path reaches from the focus node.")
        }

        Property("focusNode") {
            Type(RDF.Property)
            Label("focusNode")
            Comment("The node a path expression starts from.")
        }

        Property("concat") {
            Type(RDF.Property)
            Label("concat")
            Comment("The concatenated outputs of the expressions of the list.")
        }

        Property("remove") {
            Type(RDF.Property)
            Label("remove")
            Comment("The input nodes without the output of the expression.")
        }

        Property("flatMap") {
            Type(RDF.Property)
            Label("flatMap")
            Comment("The outputs of the expression for each input node.")
        }

        Property("limit") {
            Type(RDF.Property)
            Label("limit")
            Comment("At most this many of the input nodes.")
        }

        Property("offset") {
            Type(RDF.Property)
            Label("offset")
            Comment("The input nodes after skipping this many.")
        }

        Property("findFirst") {
            Type(RDF.Property)
            Label("findFirst")
            Comment("The first input node that conforms to the shape.")
        }

        Property("orderBy") {
            Type(RDF.Property)
            Label("orderBy")
            Comment("The input nodes ordered by the key expression.")
        }

        Property("desc") {
            Type(RDF.Property)
            Label("desc")
            Comment("Whether an ordering is descending.")
        }

        Property("union") {
            Type(RDF.Property)
            Label("union")
            Comment("The union of the outputs of the expressions of the list.")
        }

        Property("intersection") {
            Type(RDF.Property)
            Label("intersection")
            Comment("The intersection of the outputs of the expressions of the list.")
        }
    }
}


namespace Phtuning\Mvc\Model;

class Manager extends \Phalcon\Mvc\Model\Manager
{
    public function setLazyLink(record, string! alias, referenced)
    {
        var relation, field, fields, conditions, placeholders, findParams,
                arguments, referencedFields, refPosition, uniqueKey;

        let conditions = [],
            placeholders = [],
            relation = this->getRelationByAlias(get_class(record), alias);

        /**
         * It was written based on the following:
         * https://github.com/phalcon/cphalcon/blob/2.0.0/phalcon/mvc/model/manager.zep#L1297
         * after
         * https://github.com/phalcon/cphalcon/blob/65b563d95b9ebd019e185b5f81b5cbf6a3a2d35d/phalcon/mvc/model/manager.zep#L1268
         */

        /**
         * Appends conditions created from the fields defined in the relation
         */
        let fields = relation->getFields();
        if typeof fields != "array" {
            let conditions[] = "[". relation->getReferencedFields() . "] = :APR0:",
                placeholders["APR0"] = record->readAttribute(fields);
        } else {

            /**
             * Compound relation
             */
            let referencedFields = relation->getReferencedFields();
            for refPosition, field in relation->getReferencedFields() {
                let conditions[] = "[". referencedFields[refPosition] . "] = :APR" . refPosition . ":",
                    placeholders["APR" . refPosition] = record->readAttribute(field);
            }
        }

        /**
         * We don't trust the user or data in the database so we use bound parameters
         * Create a valid params array to pass to the find/findFirst method
         */
        let findParams = [
            join(" AND ", conditions),
            "bind"      : placeholders,
            "di"        : record->{"getDi"}()
        ];

        let arguments = [findParams];

        let uniqueKey = unique_key(relation->getReferencedModel(), arguments);

        this->setReusableRecords(alias, uniqueKey, referenced);
    }
}

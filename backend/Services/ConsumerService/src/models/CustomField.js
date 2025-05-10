const { DataTypes } = require('sequelize');
const { sequelize } = require('../../../../Shared/database');
const Service = require('./Service');

const CustomField = sequelize.define('CustomField', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  serviceId: {
    type: DataTypes.UUID,
    allowNull: false,
    field: 'service_id',
    references: {
      model: Service,
      key: 'id'
    }
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  type: {
    type: DataTypes.ENUM('text', 'number', 'boolean', 'selection'),
    allowNull: false
  },
  isRequired: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'is_required'
  },
  options: {
    type: DataTypes.JSON,  // 선택형 필드일 경우 옵션 목록
    allowNull: true
  },
  defaultValue: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'default_value'
  }
}, {
  timestamps: true,
  tableName: 'custom_fields'
});

// Define associations
CustomField.belongsTo(Service, { foreignKey: 'serviceId' });
Service.hasMany(CustomField, { foreignKey: 'serviceId', as: 'customFields' });

module.exports = CustomField;